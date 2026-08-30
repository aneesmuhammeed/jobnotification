import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobnoti/core/constants/app_constants.dart';
import 'package:jobnoti/core/error/exceptions.dart';
import 'package:jobnoti/features/applications/data/models/application_model.dart';

/// Abstract application data source.
abstract class ApplicationRemoteDataSource {
  Future<ApplicationModel> markAsApplied(Map<String, dynamic> data);
  Future<List<ApplicationModel>> getApplications(String userId);
  Future<ApplicationModel?> getApplicationByJob({
    required String userId,
    required String jobId,
  });
}

/// Supabase implementation of [ApplicationRemoteDataSource].
class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final SupabaseClient supabaseClient;

  ApplicationRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ApplicationModel> markAsApplied(Map<String, dynamic> data) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.applicationsTable)
          .insert(data)
          .select('*, jobs(company_name, job_title)')
          .single();

      return ApplicationModel.fromJson(response);
    } on PostgrestException catch (e) {
      // Check for unique constraint violation
      if (e.code == '23505') {
        throw const DuplicateException('You have already applied to this job.');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApplicationModel>> getApplications(String userId) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.applicationsTable)
          .select('*, jobs(company_name, job_title)')
          .eq('user_id', userId)
          .order('applied_at', ascending: false);

      return (response as List)
          .map((json) => ApplicationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ApplicationModel?> getApplicationByJob({
    required String userId,
    required String jobId,
  }) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.applicationsTable)
          .select('*, jobs(company_name, job_title)')
          .eq('user_id', userId)
          .eq('job_id', jobId)
          .maybeSingle();

      if (response == null) return null;
      return ApplicationModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
