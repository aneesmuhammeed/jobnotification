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

-- =========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =========================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

-- PROFILES
-- Users can read their own profile
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (during sign up)
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- JOBS
-- Anyone (authenticated or not) can view active jobs
CREATE POLICY "Anyone can view active jobs" ON jobs
  FOR SELECT USING (is_active = true);

-- Only Admins can insert/update/delete jobs
CREATE POLICY "Admins can manage jobs" ON jobs
  FOR ALL 
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

-- APPLICATIONS
-- Users can view their own applications
CREATE POLICY "Users can view own applications" ON applications
  FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own applications
CREATE POLICY "Users can insert own applications" ON applications
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can delete their own applications
CREATE POLICY "Users can delete own applications" ON applications
  FOR DELETE USING (auth.uid() = user_id);
