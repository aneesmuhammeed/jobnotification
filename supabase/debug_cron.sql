-- 1. Check if the cron job is failing
SELECT runid, jobid, status, return_message, start_time, end_time 
FROM cron.job_run_details 
ORDER BY start_time DESC 
LIMIT 5;

-- 2. Check if your profile actually has the updated reminder time
SELECT email, full_name, daily_reminder_enabled, reminder_time_utc, fcm_token
FROM profiles
JOIN auth.users ON profiles.id = auth.users.id;
