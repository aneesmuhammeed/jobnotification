import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobnoti/core/constants/app_constants.dart';
import 'package:jobnoti/core/error/exceptions.dart';
import 'package:jobnoti/features/jobs/data/models/job_model.dart';

/// Abstract job data source.
abstract class JobRemoteDataSource {
  Future<List<JobModel>> getJobs();
  Future<List<JobModel>> getJobsByAdmin(String adminId);
  Future<JobModel> getJobById(String jobId);
  Future<JobModel> createJob(Map<String, dynamic> jobData);
  Future<JobModel> updateJob(String jobId, Map<String, dynamic> jobData);
  Future<void> deleteJob(String jobId);
}

/// Supabase implementation of [JobRemoteDataSource].
class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final SupabaseClient supabaseClient;

  JobRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<JobModel>> getJobs() async {
    try {
      final response = await supabaseClient
          .from(AppConstants.jobsTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobModel>> getJobsByAdmin(String adminId) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.jobsTable)
          .select()
          .eq('created_by', adminId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> getJobById(String jobId) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.jobsTable)
          .select()
          .eq('id', jobId)
          .single();

      return JobModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> createJob(Map<String, dynamic> jobData) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.jobsTable)
          .insert(jobData)
          .select()
          .single();

      return JobModel.fromJson(response);
    } catch (e, stack) {
      print('=== CREATE JOB ERROR ===');
      print(e.toString());
      if (e is PostgrestException) {
        print('Code: ${e.code}');
        print('Details: ${e.details}');
        print('Hint: ${e.hint}');
        print('Message: ${e.message}');
      }
      print('========================');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> updateJob(String jobId, Map<String, dynamic> jobData) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.jobsTable)
          .update(jobData)
          .eq('id', jobId)
          .select()
          .single();

      return JobModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    try {
      await supabaseClient
          .from(AppConstants.jobsTable)
          .delete()
          .eq('id', jobId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
