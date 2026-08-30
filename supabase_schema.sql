-- Supabase Schema for JobNoti (MVP - No RLS)

-- 1. Create Profiles Table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  role TEXT DEFAULT 'user' NOT NULL,
  fcm_token TEXT,
  notification_enabled BOOLEAN DEFAULT true
);

-- 2. Create Jobs Table
CREATE TABLE jobs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  company_name TEXT NOT NULL,
  job_title TEXT NOT NULL,
  description TEXT NOT NULL,
  application_url TEXT NOT NULL,
  last_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  is_active BOOLEAN DEFAULT TRUE NOT NULL
);

-- 3. Create Applications Table
CREATE TABLE applications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  job_id UUID REFERENCES jobs(id) ON DELETE CASCADE NOT NULL,
  applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  document_path TEXT,
  document_name TEXT,
  UNIQUE(user_id, job_id) -- A user can apply to a specific job only once
);
