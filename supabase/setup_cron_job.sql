-- ====================================================================
-- SETUP SUPABASE CRON JOB FOR DAILY REMINDERS
-- Run this in your Supabase Dashboard SQL Editor
-- ====================================================================

-- 1. Ensure required extensions are active
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 2. Add columns to profiles table if they don't exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS daily_reminder_enabled BOOLEAN DEFAULT true;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS reminder_time_utc TIME DEFAULT '12:30:00';

-- 3. Schedule the cron job to run every minute
-- NOTE: Replace 'YOUR_PROJECT_URL' and 'YOUR_SERVICE_ROLE_KEY' before running!
SELECT cron.schedule(
  'send_daily_reminders',
  '* * * * *',
  $$
    DO $block$
    DECLARE
      tokens jsonb;
    BEGIN
      -- Gather all FCM tokens where the reminder_time_utc exactly matches the current UTC minute
      SELECT jsonb_agg(fcm_token) INTO tokens
      FROM profiles
      WHERE daily_reminder_enabled = true
      AND fcm_token IS NOT NULL
      AND fcm_token != ''
      AND to_char(reminder_time_utc, 'HH24:MI') = to_char(now() at time zone 'utc', 'HH24:MI');

      -- If there are tokens for this minute, send them to the Edge Function
      IF tokens IS NOT NULL THEN
        PERFORM net.http_post(
          url := 'https://uzetypkxgoegwzmvbsvs.supabase.co/functions/v1/send-daily-reminder',
          headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6ZXR5cGt4Z29lZ3d6bXZic3ZzIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODEwMTg5MiwiZXhwIjoyMTAzNjc3ODkyfQ.gwt1fgBAq_eEmt_EnQ79V6W9-LaPyaiu4jYbOrZ9SRU'
          ),
          body := jsonb_build_object('tokens', tokens)
        );
      END IF;
    END;
    $block$;
  $$
);

-- ====================================================================
-- HELPER COMMANDS (Do NOT run unless you want to remove/check the cron job)
-- ====================================================================
-- View active cron jobs:
-- SELECT * FROM cron.job;

-- Unschedule this job:
-- SELECT cron.unschedule('send_daily_reminders');
