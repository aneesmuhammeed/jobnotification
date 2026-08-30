import 'package:equatable/equatable.dart';
import 'package:jobnoti/features/applications/domain/entities/application_entity.dart';

/// Application BLoC events.
abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];
}

class MarkAsAppliedRequested extends ApplicationEvent {
  final String userId;
  final String jobId;
  final String? documentPath;
  final String? documentName;

  const MarkAsAppliedRequested({
    required this.userId,
    required this.jobId,
    this.documentPath,
    this.documentName,
  });

  @override
  List<Object?> get props => [userId, jobId, documentPath, documentName];
}

class LoadApplicationsRequested extends ApplicationEvent {
  final String userId;

  const LoadApplicationsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CheckApplicationStatusRequested extends ApplicationEvent {
  final String userId;
  final String jobId;

  const CheckApplicationStatusRequested({
    required this.userId,
    required this.jobId,
  });

  @override
  List<Object?> get props => [userId, jobId];
}

/// Application BLoC states.
abstract class ApplicationState extends Equatable {
  const ApplicationState();

  @override
  List<Object?> get props => [];
}

class ApplicationInitial extends ApplicationState {
  const ApplicationInitial();
}

class ApplicationLoading extends ApplicationState {
  const ApplicationLoading();
}

class ApplicationsLoaded extends ApplicationState {
  final List<ApplicationEntity> applications;

  const ApplicationsLoaded(this.applications);

  @override
  List<Object?> get props => [applications];
}

class ApplicationMarked extends ApplicationState {
  final ApplicationEntity application;

  const ApplicationMarked(this.application);

  @override
  List<Object?> get props => [application];
}

class ApplicationStatusChecked extends ApplicationState {
  final ApplicationEntity? application;

  const ApplicationStatusChecked(this.application);

  bool get hasApplied => application != null;

  @override
  List<Object?> get props => [application];
}

class ApplicationError extends ApplicationState {
  final String message;

  const ApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}
