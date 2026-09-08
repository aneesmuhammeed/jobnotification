import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";
import { initializeApp, cert } from "npm:firebase-admin/app";
import { getMessaging } from "npm:firebase-admin/messaging";

// Initialize Firebase Admin (lazy loaded on first request)
let firebaseInitialized = false;

serve(async (req) => {
  try {
    const payload = await req.json();

    // Verify it's an INSERT trigger payload from Supabase
    if (payload.type !== "INSERT" || payload.table !== "jobs") {
      return new Response(JSON.stringify({ message: "Ignoring non-insert or non-jobs payload" }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }

    const newJob = payload.record;
    console.log(`Processing new job notification: ${newJob.job_title}`);

    // Initialize Firebase Admin if not already initialized
    if (!firebaseInitialized) {
      const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
      if (!serviceAccountJson) {
        throw new Error("FIREBASE_SERVICE_ACCOUNT environment variable is missing.");
      }
      const serviceAccount = JSON.parse(serviceAccountJson);
      
      initializeApp({
        credential: cert(serviceAccount),
      });
      firebaseInitialized = true;
    }

    // Initialize Supabase Client to fetch users
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Fetch all users with FCM tokens who have notifications enabled
    const { data: profiles, error } = await supabase
      .from("profiles")
      .select("fcm_token")
      .eq("notification_enabled", true)
      .not("fcm_token", "is", null);

    if (error) {
      console.error("Error fetching profiles:", error);
      throw error;
    }

    if (!profiles || profiles.length === 0) {
      console.log("No valid fcm_tokens found. Skipping notifications.");
      return new Response(JSON.stringify({ message: "No tokens found" }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }

    const tokens = profiles.map((p) => p.fcm_token).filter((t) => t.trim() !== "");
    
    if (tokens.length === 0) {
       return new Response(JSON.stringify({ message: "No valid tokens found" }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }

    // Construct the notification payload
    const message = {
      notification: {
        title: "New Job Alert!",
        body: `${newJob.company_name} is hiring a ${newJob.job_title}. Apply now!`,
      },
      data: {
        job_id: newJob.id,
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      },
      tokens: tokens,
    };

    // Send multicast message using Firebase Admin
    const response = await getMessaging().sendEachForMulticast(message);
    
    console.log(`${response.successCount} messages were sent successfully`);
    if (response.failureCount > 0) {
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
          console.error(`Failed token: ${tokens[idx]} - Error: ${resp.error?.message}`);
        }
      });
      
      // Optional: Clean up failed tokens from the database if they are invalid
      // This helps keep the database clean and prevents sending to stale tokens.
    }

    return new Response(
      JSON.stringify({ 
        message: "Notifications processed",
        successCount: response.successCount,
        failureCount: response.failureCount
      }),
      {
        headers: { "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (err) {
    console.error("Function error:", err);
    return new Response(String(err?.message ?? err), { status: 500 });
  }
});
