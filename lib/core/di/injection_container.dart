import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobnoti/core/network/supabase_client_wrapper.dart';
import 'package:jobnoti/core/services/notification_service.dart';

// Features - Auth
import 'package:jobnoti/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:jobnoti/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jobnoti/features/auth/domain/repositories/auth_repository.dart';
import 'package:jobnoti/features/auth/domain/usecases/login.dart';
import 'package:jobnoti/features/auth/domain/usecases/register.dart';
import 'package:jobnoti/features/auth/domain/usecases/logout.dart';
import 'package:jobnoti/features/auth/domain/usecases/get_current_user.dart';
import 'package:jobnoti/features/auth/domain/usecases/toggle_notifications.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_bloc.dart';

// Features - Jobs
import 'package:jobnoti/features/jobs/data/datasources/job_remote_data_source.dart';
import 'package:jobnoti/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:jobnoti/features/jobs/domain/repositories/job_repository.dart';
import 'package:jobnoti/features/jobs/domain/usecases/get_jobs.dart';
import 'package:jobnoti/features/jobs/domain/usecases/get_job_by_id.dart';
import 'package:jobnoti/features/jobs/domain/usecases/create_job.dart';
import 'package:jobnoti/features/jobs/domain/usecases/update_job.dart';
import 'package:jobnoti/features/jobs/domain/usecases/delete_job.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_bloc.dart';

// Features - Applications
import 'package:jobnoti/features/applications/data/datasources/application_remote_data_source.dart';
import 'package:jobnoti/features/applications/data/repositories/application_repository_impl.dart';
import 'package:jobnoti/features/applications/domain/repositories/application_repository.dart';
import 'package:jobnoti/features/applications/domain/usecases/mark_job_as_applied.dart';
import 'package:jobnoti/features/applications/domain/usecases/get_applications.dart';
import 'package:jobnoti/features/applications/domain/usecases/get_application_by_job.dart';
import 'package:jobnoti/features/applications/presentation/bloc/application_bloc.dart';

final sl = GetIt.instance;

/// Initialize all dependencies.
Future<void> initDependencies() async {
  // ─── External ─────────────────────────────────────────
  sl.registerLazySingleton<SupabaseClient>(
    () => SupabaseClientWrapper.client,
  );
  sl.registerLazySingleton(() => NotificationService());

  // ─── Auth Feature ─────────────────────────────────────
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      supabaseClient: sl(),
      notificationService: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => ToggleNotifications(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      login: sl(),
      register: sl(),
      logout: sl(),
      getCurrentUser: sl(),
      toggleNotifications: sl(),
    ),
  );

  // ─── Jobs Feature ─────────────────────────────────────
  // Data sources
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetJobs(sl()));
  sl.registerLazySingleton(() => GetJobById(sl()));
  sl.registerLazySingleton(() => CreateJob(sl()));
  sl.registerLazySingleton(() => UpdateJob(sl()));
  sl.registerLazySingleton(() => DeleteJob(sl()));

  // BLoC
  sl.registerFactory(
    () => JobBloc(
      getJobs: sl(),
      getJobById: sl(),
      createJob: sl(),
      updateJob: sl(),
      deleteJob: sl(),
    ),
  );

  // ─── Applications Feature ────────────────────────────
  // Data sources
  sl.registerLazySingleton<ApplicationRemoteDataSource>(
    () => ApplicationRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ApplicationRepository>(
    () => ApplicationRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => MarkJobAsApplied(sl()));
  sl.registerLazySingleton(() => GetApplications(sl()));
  sl.registerLazySingleton(() => GetApplicationByJob(sl()));

  // BLoC
  sl.registerFactory(
    () => ApplicationBloc(
      markJobAsApplied: sl(),
      getApplications: sl(),
      getApplicationByJob: sl(),
    ),
  );
}
