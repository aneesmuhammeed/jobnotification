import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobnoti/features/applications/domain/usecases/mark_job_as_applied.dart';
import 'package:jobnoti/features/applications/domain/usecases/get_applications.dart';
import 'package:jobnoti/features/applications/domain/usecases/get_application_by_job.dart';
import 'package:jobnoti/features/applications/presentation/bloc/application_event_state.dart';

/// Application BLoC — manages application tracking state.
class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final MarkJobAsApplied markJobAsApplied;
  final GetApplications getApplications;
  final GetApplicationByJob getApplicationByJob;

  ApplicationBloc({
    required this.markJobAsApplied,
    required this.getApplications,
    required this.getApplicationByJob,
  }) : super(const ApplicationInitial()) {
    on<MarkAsAppliedRequested>(_onMarkAsApplied);
    on<LoadApplicationsRequested>(_onLoadApplications);
    on<CheckApplicationStatusRequested>(_onCheckApplicationStatus);
  }

  Future<void> _onMarkAsApplied(
    MarkAsAppliedRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(const ApplicationLoading());
    final result = await markJobAsApplied(
      MarkJobAsAppliedParams(
        userId: event.userId,
        jobId: event.jobId,
        documentPath: event.documentPath,
        documentName: event.documentName,
      ),
    );
    result.fold(
      (failure) => emit(ApplicationError(failure.message)),
      (application) => emit(ApplicationMarked(application)),
    );
  }

  Future<void> _onLoadApplications(
    LoadApplicationsRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(const ApplicationLoading());
    final result = await getApplications(
      GetApplicationsParams(userId: event.userId),
    );
    result.fold(
      (failure) => emit(ApplicationError(failure.message)),
      (applications) => emit(ApplicationsLoaded(applications)),
    );
  }

  Future<void> _onCheckApplicationStatus(
    CheckApplicationStatusRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    final result = await getApplicationByJob(
      GetApplicationByJobParams(userId: event.userId, jobId: event.jobId),
    );
    result.fold(
      (failure) => emit(ApplicationError(failure.message)),
      (application) => emit(ApplicationStatusChecked(application)),
    );
  }
}
