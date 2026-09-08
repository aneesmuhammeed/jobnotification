-- 1. Create a trigger function that calls the Supabase Edge Function
CREATE OR REPLACE FUNCTION public.trigger_job_notification()
RETURNS TRIGGER AS $$
DECLARE
  req_headers jsonb;
  req_host text;
  req_auth text;
BEGIN
  -- Safely extract headers
  req_headers := coalesce(current_setting('request.headers', true), '{}')::jsonb;
  req_host := req_headers->>'host';
  req_auth := req_headers->>'authorization';

  -- Fallback if host is missing (e.g., when inserting from Supabase dashboard instead of app)
  IF req_host IS NULL THEN
    -- If we don't have a host, we cannot call the edge function properly via relative URL
    -- We just return NEW to not block the database insert
    RETURN NEW;
  END IF;

  PERFORM net.http_post(
    url := 'https://' || req_host || '/functions/v1/send-job-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', coalesce(req_auth, '')
    ),
    body := jsonb_build_object(
      'type', TG_OP,
      'table', TG_TABLE_NAME,
      'schema', TG_TABLE_SCHEMA,
      'record', row_to_json(NEW)
    )
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Attach the trigger to the jobs table
DROP TRIGGER IF EXISTS on_job_created_send_notification ON public.jobs;
CREATE TRIGGER on_job_created_send_notification
  AFTER INSERT ON public.jobs
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_job_notification();
