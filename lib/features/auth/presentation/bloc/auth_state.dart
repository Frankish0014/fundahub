part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  registered,
  authenticated,
  passwordResetSent,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.selectedRole,
    this.selectedInterests = const [],
    this.user,
    this.errorMessage,
    this.infoMessage,
  });

  final AuthStatus status;
  final String fullName;
  final String email;
  final String password;
  final String? selectedRole;
  final List<String> selectedInterests;
  final UserProfile? user;
  final String? errorMessage;
  final String? infoMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? fullName,
    String? email,
    String? password,
    String? selectedRole,
    List<String>? selectedInterests,
    UserProfile? user,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    fullName,
    email,
    password,
    selectedRole,
    selectedInterests,
    user,
    errorMessage,
    infoMessage,
  ];
}
