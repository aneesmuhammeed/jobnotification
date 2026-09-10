import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/jobs/domain/usecases/get_jobs.dart';
import 'package:jobnoti/features/jobs/domain/usecases/get_job_by_id.dart';
import 'package:jobnoti/features/jobs/domain/usecases/create_job.dart';
import 'package:jobnoti/features/jobs/domain/usecases/update_job.dart';
import 'package:jobnoti/features/jobs/domain/usecases/delete_job.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_event_state.dart';

/// Job BLoC — manages job listing and CRUD state.
class JobBloc extends Bloc<JobEvent, JobState> {
  final GetJobs getJobs;
  final GetJobById getJobById;
  final CreateJob createJob;
  final UpdateJob updateJob;
  final DeleteJob deleteJob;

  JobBloc({
    required this.getJobs,
    required this.getJobById,
    required this.createJob,
    required this.updateJob,
    required this.deleteJob,
  }) : super(const JobInitial()) {
    on<LoadJobsRequested>(_onLoadJobs);
    on<LoadJobDetailsRequested>(_onLoadJobDetails);
    on<CreateJobRequested>(_onCreateJob);
    on<UpdateJobRequested>(_onUpdateJob);
    on<DeleteJobRequested>(_onDeleteJob);
    on<LoadAdminJobsRequested>(_onLoadAdminJobs);
  }

  Future<void> _onLoadJobs(
    LoadJobsRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    final result = await getJobs(const NoParams());
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (jobs) => emit(JobsLoaded(jobs)),
    );
  }

  Future<void> _onLoadAdminJobs(
    LoadAdminJobsRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    // Use getJobs and filter by admin — alternatively add a dedicated use case
    final result = await getJobs(const NoParams());
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (jobs) {
        final adminJobs = jobs.where((j) => j.createdBy == event.adminId).toList();
        emit(JobsLoaded(adminJobs));
      },
    );
  }

  Future<void> _onLoadJobDetails(
    LoadJobDetailsRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    final result = await getJobById(
      GetJobByIdParams(jobId: event.jobId),
    );
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (job) => emit(JobDetailLoaded(job)),
    );
  }

  Future<void> _onCreateJob(
    CreateJobRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    final result = await createJob(
      CreateJobParams(
        companyName: event.companyName,
        jobTitle: event.jobTitle,
        description: event.description,
        applicationUrls: event.applicationUrls,
        lastDate: event.lastDate,
        createdBy: event.createdBy,
      ),
    );
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (job) => emit(JobCreated(job)),
    );
  }

  Future<void> _onUpdateJob(
    UpdateJobRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    final result = await updateJob(
      UpdateJobParams(
        jobId: event.jobId,
        companyName: event.companyName,
        jobTitle: event.jobTitle,
        description: event.description,
        applicationUrls: event.applicationUrls,
        lastDate: event.lastDate,
        isActive: event.isActive,
      ),
    );
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (job) => emit(JobUpdated(job)),
    );
  }

  Future<void> _onDeleteJob(
    DeleteJobRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    final result = await deleteJob(
      DeleteJobParams(jobId: event.jobId),
    );
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (_) => emit(const JobDeleted()),
    );
  }
}
