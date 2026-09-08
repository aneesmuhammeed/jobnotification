/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'JobNoti';
  static const String supabaseUrl = 'https://uzetypkxgoegwzmvbsvs.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6ZXR5cGt4Z29lZ3d6bXZic3ZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgxMDE4OTIsImV4cCI6MjEwMzY3Nzg5Mn0.w9vt90ReSXSa0-2PMQ5FXhtoULEi19Phrt2rMHP003U';

  // Supabase table names
  static const String profilesTable = 'profiles';
  static const String jobsTable = 'jobs';
  static const String applicationsTable = 'applications';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Default notification time (8:00 PM)
  static const int defaultNotificationHour = 20;
  static const int defaultNotificationMinute = 0;

  // Local document storage directory name
  static const String documentsDir = 'jobnoti_documents';

  // Telegram Cloud Storage settings
  // Replace these with your actual Bot Token and Group Chat ID
  static const String telegramBotToken = '8107955995:AAGoc6EAjGRsWbXqDqAsdwX25hXd_zttw08';
  static const String telegramChatId = '-1003741865575';
}
