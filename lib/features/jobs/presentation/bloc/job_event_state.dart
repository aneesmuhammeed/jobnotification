import 'package:equatable/equatable.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';

/// Job BLoC events.
abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobsRequested extends JobEvent {
  const LoadJobsRequested();
}

class LoadAdminJobsRequested extends JobEvent {
  final String adminId;
  const LoadAdminJobsRequested({required this.adminId});

  @override
  List<Object?> get props => [adminId];
}

class LoadJobDetailsRequested extends JobEvent {
  final String jobId;
  const LoadJobDetailsRequested({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

class CreateJobRequested extends JobEvent {
  final String companyName;
  final String jobTitle;
  final String description;
  final String applicationUrl;
  final DateTime lastDate;
  final String createdBy;

  const CreateJobRequested({
    required this.companyName,
    required this.jobTitle,
    required this.description,
    required this.applicationUrl,
    required this.lastDate,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        companyName, jobTitle, description,
        applicationUrl, lastDate, createdBy,
      ];
}

class UpdateJobRequested extends JobEvent {
  final String jobId;
  final String companyName;
  final String jobTitle;
  final String description;
  final String applicationUrl;
  final DateTime lastDate;
  final bool isActive;

  const UpdateJobRequested({
    required this.jobId,
    required this.companyName,
    required this.jobTitle,
    required this.description,
    required this.applicationUrl,
    required this.lastDate,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        jobId, companyName, jobTitle, description,
        applicationUrl, lastDate, isActive,
      ];
}

class DeleteJobRequested extends JobEvent {
  final String jobId;
  const DeleteJobRequested({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Job BLoC states.
abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {
  const JobInitial();
}

class JobLoading extends JobState {
  const JobLoading();
}

class JobsLoaded extends JobState {
  final List<JobEntity> jobs;
  const JobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class JobDetailLoaded extends JobState {
  final JobEntity job;
  const JobDetailLoaded(this.job);

  @override
  List<Object?> get props => [job];
}

class JobCreated extends JobState {
  final JobEntity job;
  const JobCreated(this.job);

  @override
  List<Object?> get props => [job];
}

class JobUpdated extends JobState {
  final JobEntity job;
  const JobUpdated(this.job);

  @override
  List<Object?> get props => [job];
}

class JobDeleted extends JobState {
  const JobDeleted();
}

class JobError extends JobState {
  final String message;
  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}
