import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton wrapper around the Supabase client.
///
/// Initialize via [SupabaseClientWrapper.initialize] in main.dart,
/// then access the client via [SupabaseClientWrapper.client].
class SupabaseClientWrapper {
  SupabaseClientWrapper._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase. Call this once in main.dart before runApp.
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
    );
  }
}
