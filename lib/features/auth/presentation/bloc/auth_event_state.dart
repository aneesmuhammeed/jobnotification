import 'package:equatable/equatable.dart';
import 'package:jobnoti/features/auth/domain/entities/user_entity.dart';

/// Auth BLoC events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthRequested extends AuthEvent {
  const CheckAuthRequested();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class ToggleNotificationsRequested extends AuthEvent {
  final bool enabled;

  const ToggleNotificationsRequested(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateDailyReminderRequested extends AuthEvent {
  final bool enabled;
  final String timeUtc;

  const UpdateDailyReminderRequested(this.enabled, this.timeUtc);

  @override
  List<Object?> get props => [enabled, timeUtc];
}

/// Auth BLoC states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
