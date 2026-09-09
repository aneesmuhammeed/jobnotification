import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://uzetypkxgoegwzmvbsvs.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6ZXR5cGt4Z29lZ3d6bXZic3ZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgxMDE4OTIsImV4cCI6MjEwMzY3Nzg5Mn0.w9vt90ReSXSa0-2PMQ5FXhtoULEi19Phrt2rMHP003U'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
