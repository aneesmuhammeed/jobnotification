import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/auth/domain/usecases/login.dart';
import 'package:jobnoti/features/auth/domain/usecases/register.dart';
import 'package:jobnoti/features/auth/domain/usecases/logout.dart';
import 'package:jobnoti/features/auth/domain/usecases/get_current_user.dart';
import 'package:jobnoti/features/auth/domain/usecases/toggle_notifications.dart';
import 'package:jobnoti/features/auth/domain/usecases/update_daily_reminder.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_event_state.dart';
import 'package:jobnoti/features/auth/domain/entities/user_entity.dart';

/// Auth BLoC — manages authentication state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Register register;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final ToggleNotifications toggleNotifications;
  final UpdateDailyReminder updateDailyReminder;

  AuthBloc({
    required this.login,
    required this.register,
    required this.logout,
    required this.getCurrentUser,
    required this.toggleNotifications,
    required this.updateDailyReminder,
  }) : super(const AuthInitial()) {
    on<CheckAuthRequested>(_onCheckAuth);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<ToggleNotificationsRequested>(_onToggleNotifications);
    on<UpdateDailyReminderRequested>(_onUpdateDailyReminder);
  }

  Future<void> _onCheckAuth(
    CheckAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getCurrentUser(const NoParams());
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await login(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await register(
      RegisterParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await logout(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onToggleNotifications(
    ToggleNotificationsRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final user = (state as Authenticated).user;
      
      // Optimistic update
      final updatedUser = UserEntity(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        notificationEnabled: event.enabled,
        dailyReminderEnabled: user.dailyReminderEnabled,
        reminderTimeUtc: user.reminderTimeUtc,
      );
      emit(Authenticated(updatedUser));

      final result = await toggleNotifications(event.enabled);
      result.fold(
        (failure) {
          emit(AuthError(failure.message));
          emit(Authenticated(user)); // Rollback
        },
        (user) => emit(Authenticated(user)),
      );
    }
  }

  Future<void> _onUpdateDailyReminder(
    UpdateDailyReminderRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final user = (state as Authenticated).user;
      
      // Optimistic update
      final updatedUser = UserEntity(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        notificationEnabled: user.notificationEnabled,
        dailyReminderEnabled: event.enabled,
        reminderTimeUtc: event.timeUtc,
      );
      emit(Authenticated(updatedUser));

      final result = await updateDailyReminder(
        UpdateDailyReminderParams(enabled: event.enabled, timeUtc: event.timeUtc),
      );
      result.fold(
        (failure) {
          emit(AuthError(failure.message));
          emit(Authenticated(user)); // Rollback
        },
        (user) => emit(Authenticated(user)),
      );
    }
  }
}
