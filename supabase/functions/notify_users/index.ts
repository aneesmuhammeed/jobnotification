import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { JWT } from "https://npm.esm.sh/google-auth-library@8.7.0";

// Interface for Webhook payload (triggered by INSERT on jobs table)
interface WebhookPayload {
  type: "INSERT";
  table: string;
  schema: string;
  record: {
    id: string;
    job_title: string;
    company_name: string;
    description: string;
  };
}

serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json();

    if (payload.type !== "INSERT" || payload.table !== "jobs") {
      return new Response(JSON.stringify({ message: "Ignoring non-insert or non-jobs event" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const job = payload.record;

    // Initialize Supabase Client
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // Fetch users who have notifications enabled and a valid FCM token
    const { data: users, error: usersError } = await supabase
      .from("profiles")
      .select("id, fcm_token")
      .eq("notification_enabled", true)
      .not("fcm_token", "is", null);

    if (usersError) {
      throw new Error(`Error fetching users: ${usersError.message}`);
    }

    if (!users || users.length === 0) {
      return new Response(JSON.stringify({ message: "No users to notify" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // Since this is a newly inserted job, NO user has applied for it yet.
    // However, if this was a cron job sending daily digests, we would do:
    // .not('id', 'in', `(select user_id from applications where job_id = '${job.id}')`)
    
    // For MVP Webhook trigger (immediately on Job Insert):
    // All these users are eligible.
    const tokens = users.map((u) => u.fcm_token).filter(Boolean);

    if (tokens.length === 0) {
      return new Response(JSON.stringify({ message: "No valid FCM tokens found" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // Initialize Firebase Admin (Requires service account JSON as Env Var)
    // Setup Service Account logic
    const serviceAccountStr = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!serviceAccountStr) {
      throw new Error("FIREBASE_SERVICE_ACCOUNT env var missing");
    }
    const serviceAccount = JSON.parse(serviceAccountStr);

    const getAccessToken = async () => {
      const client = new JWT({
        email: serviceAccount.client_email,
        key: serviceAccount.private_key,
        scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
      });
      const token = await client.getAccessToken();
      return token.token;
    };

    const accessToken = await getAccessToken();

    // Send via FCM HTTP v1 API
    const projectId = serviceAccount.project_id;
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    let successCount = 0;
    let failureCount = 0;

    for (const token of tokens) {
      const message = {
        message: {
          token: token,
          notification: {
            title: `New Job: ${job.job_title} at ${job.company_name}`,
            body: job.description.length > 100 ? job.description.substring(0, 100) + "..." : job.description,
          },
          data: {
            jobId: job.id,
          },
        },
      };

      const fcmResponse = await fetch(fcmUrl, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(message),
      });

      if (fcmResponse.ok) {
        successCount++;
      } else {
        failureCount++;
        console.error(`Failed to send to ${token}:`, await fcmResponse.text());
      }
    }

    return new Response(JSON.stringify({ message: `Sent ${successCount} notifications, ${failureCount} failed` }), {
      headers: { "Content-Type": "application/json" },
    });

  } catch (error: any) {
    console.error("Error sending notifications:", error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
