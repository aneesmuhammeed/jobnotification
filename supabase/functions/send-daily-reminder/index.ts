import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { initializeApp, cert } from "npm:firebase-admin/app";
import { getMessaging } from "npm:firebase-admin/messaging";

// Initialize Firebase Admin (lazy loaded on first request)
let firebaseInitialized = false;

serve(async (req) => {
  try {
    const payload = await req.json();

    // Verify it's a cron payload containing tokens
    if (!payload.tokens || !Array.isArray(payload.tokens)) {
      return new Response(JSON.stringify({ message: "Invalid payload: missing tokens array" }), {
        headers: { "Content-Type": "application/json" },
        status: 400,
      });
    }

    const tokens = payload.tokens;
    console.log(`Processing daily reminders for ${tokens.length} tokens.`);

    if (tokens.length === 0) {
      return new Response(JSON.stringify({ message: "No tokens found" }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }

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

    // Construct the notification payload
    const message = {
      notification: {
        title: "Job Reminder",
        body: "It's time to review your unfilled job applications.",
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      },
      tokens: tokens,
    };

    // Send multicast message using Firebase Admin
    const response = await getMessaging().sendEachForMulticast(message);
    
    console.log(`${response.successCount} messages were sent successfully`);
    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`Failed token: ${tokens[idx]} - Error: ${resp.error?.message}`);
        }
      });
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
