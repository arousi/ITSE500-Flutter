abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

/// Unified loaded profile data container.
class ProfileLoaded extends ProfileState {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool emailVerified; // server email verified
  final bool profileEmailVerified; // secondary profile email flag if used
  final String userId; // server UUID

  ProfileLoaded({
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.emailVerified = false,
    this.profileEmailVerified = false,
    this.userId = '',
  });

  ProfileLoaded copyWith({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? emailVerified,
    bool? profileEmailVerified,
    String? userId,
  }) =>
      ProfileLoaded(
        username: username ?? this.username,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        emailVerified: emailVerified ?? this.emailVerified,
        profileEmailVerified: profileEmailVerified ?? this.profileEmailVerified,
        userId: userId ?? this.userId,
      );
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

/// Non-destructive error that preserves loaded data so UI sections stay expanded.
class ProfileLoadedError extends ProfileLoaded {
  final String errorMessage;
  ProfileLoadedError({
    required this.errorMessage,
    required super.username,
    required super.email,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.emailVerified,
    super.profileEmailVerified,
    super.userId,
  });
}

class ProfileVisitor extends ProfileState {} // offline visitor mode

class ProfileUnverified extends ProfileState {
  // logged-in but unverified (pre email verification)
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String userId;
  ProfileUnverified({
    this.username = '',
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.userId = '',
  });
}

class ProfileVerified extends ProfileState {}

class ProfileArchived extends ProfileState {}

class ProfileDeleted extends ProfileState {}

class ProfileLoggedOut extends ProfileState {}
