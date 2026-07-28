part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthFullNameChanged extends AuthEvent {
  const AuthFullNameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class AuthEmailChanged extends AuthEvent {
  const AuthEmailChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class AuthPasswordChanged extends AuthEvent {
  const AuthPasswordChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class AuthRoleSelected extends AuthEvent {
  const AuthRoleSelected(this.role);
  final String role;

  @override
  List<Object?> get props => [role];
}

class AuthInterestToggled extends AuthEvent {
  const AuthInterestToggled(this.tag);
  final String tag;

  @override
  List<Object?> get props => [tag];
}

class AuthRegisterSubmitted extends AuthEvent {
  const AuthRegisterSubmitted();
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted();
}

class AuthGoogleSubmitted extends AuthEvent {
  const AuthGoogleSubmitted();
}

class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthInterestsSubmitted extends AuthEvent {
  const AuthInterestsSubmitted();
}

class AuthInterestsSkipped extends AuthEvent {
  const AuthInterestsSkipped();
}
