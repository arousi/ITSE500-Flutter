// auth_state.dart
part of 'auth_cubit.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

/// Authenticated but foreground is locked pending biometric/device auth.
class AuthBiometricLocked extends AuthState {
  final DateTime lockedAt;
  final String reason; // e.g., 'startup', 'inactivity', 'manual'
  const AuthBiometricLocked({required this.lockedAt, required this.reason});
  @override
  List<Object?> get props => [lockedAt, reason];
}

/// Transitional state while invoking local_auth prompt.
class AuthBiometricAuthenticating extends AuthState {
  final DateTime startedAt;
  final String reason;
  const AuthBiometricAuthenticating(
      {required this.startedAt, required this.reason});
  @override
  List<Object?> get props => [startedAt, reason];
}

class AuthRegistrationSuccess extends AuthState {}

class AuthRegistrationNoEmailVerification extends AuthState {}

class AuthGuest extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// OAuth specific states (OpenRouter, Google, etc.)
class AuthOAuthInProgress extends AuthState {
  final String provider; // e.g., 'openrouter'
  final DateTime startedAt;
  AuthOAuthInProgress(this.provider, {DateTime? started})
      : startedAt = started ?? DateTime.now();
  @override
  List<Object?> get props => [provider, startedAt];
}

class AuthOAuthAwaitingRedirect extends AuthState {
  final String provider;
  final String stateId; // backend state identifier (if needed)
  final Uri authorizeUri;
  const AuthOAuthAwaitingRedirect(
      {required this.provider,
      required this.stateId,
      required this.authorizeUri});
  @override
  List<Object?> get props => [provider, stateId, authorizeUri.toString()];
}

class AuthOAuthCompleting extends AuthState {
  final String provider;
  const AuthOAuthCompleting(this.provider);
  @override
  List<Object?> get props => [provider];
}

class AuthOAuthError extends AuthState {
  final String provider;
  final String error;
  const AuthOAuthError(this.provider, this.error);
  @override
  List<Object?> get props => [provider, error];
}

class AuthOAuthSuccess extends AuthState {
  final String provider;
  final bool linkedSession; // true if merged into existing logged-in user
  const AuthOAuthSuccess(this.provider, {this.linkedSession = false});
  @override
  List<Object?> get props => [provider, linkedSession];
}
