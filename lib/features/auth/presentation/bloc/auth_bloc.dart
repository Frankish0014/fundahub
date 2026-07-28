import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.registerUser,
    required this.loginUser,
    required this.signInWithGoogle,
    required this.sendPasswordResetEmail,
    required this.updateUserInterests,
    required this.getCurrentUser,
  }) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthFullNameChanged>(_onFullNameChanged);
    on<AuthEmailChanged>(_onEmailChanged);
    on<AuthPasswordChanged>(_onPasswordChanged);
    on<AuthRoleSelected>(_onRoleSelected);
    on<AuthInterestToggled>(_onInterestToggled);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthGoogleSubmitted>(_onGoogleSubmitted);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthInterestsSubmitted>(_onInterestsSubmitted);
    on<AuthInterestsSkipped>(_onInterestsSkipped);
  }

  final RegisterUser registerUser;
  final LoginUser loginUser;
  final SignInWithGoogle signInWithGoogle;
  final SendPasswordResetEmail sendPasswordResetEmail;
  final UpdateUserInterests updateUserInterests;
  final GetCurrentUser getCurrentUser;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        emit(state.copyWith(user: user, status: AuthStatus.authenticated));
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onFullNameChanged(AuthFullNameChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        fullName: event.value,
        status: AuthStatus.initial,
        clearError: true,
        clearInfo: true,
      ),
    );
  }

  void _onEmailChanged(AuthEmailChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        email: event.value,
        status: AuthStatus.initial,
        clearError: true,
        clearInfo: true,
      ),
    );
  }

  void _onPasswordChanged(AuthPasswordChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        password: event.value,
        status: AuthStatus.initial,
        clearError: true,
        clearInfo: true,
      ),
    );
  }

  void _onRoleSelected(AuthRoleSelected event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        selectedRole: event.role,
        status: AuthStatus.initial,
        clearError: true,
        clearInfo: true,
      ),
    );
  }

  void _onInterestToggled(AuthInterestToggled event, Emitter<AuthState> emit) {
    final next = List<String>.from(state.selectedInterests);
    if (next.contains(event.tag)) {
      next.remove(event.tag);
    } else {
      next.add(event.tag);
    }
    emit(state.copyWith(selectedInterests: next));
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final validationError = _registrationValidationError();
    if (validationError != null) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: validationError,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      final user = await registerUser(
        fullName: state.fullName.trim(),
        email: state.email.trim(),
        password: state.password,
        role: state.selectedRole!,
      );
      emit(
        state.copyWith(
          user: user,
          status: AuthStatus.registered,
          infoMessage: 'Account created. A verification email has been sent.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (!_isValidEmail(state.email.trim())) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Please enter a valid email address.',
        ),
      );
      return;
    }
    if (state.password.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Please enter your password.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      final user = await loginUser(
        email: state.email.trim(),
        password: state.password,
      );
      emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onGoogleSubmitted(
    AuthGoogleSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      final user = await signInWithGoogle();
      emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.email.trim();
    if (!_isValidEmail(email)) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Please enter a valid email address.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        email: email,
        status: AuthStatus.loading,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      await sendPasswordResetEmail(email);
      emit(
        state.copyWith(
          status: AuthStatus.passwordResetSent,
          infoMessage: 'Password reset email sent to $email.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onInterestsSubmitted(
    AuthInterestsSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      final user = await updateUserInterests(state.selectedInterests);
      emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onInterestsSkipped(
    AuthInterestsSkipped event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(status: AuthStatus.authenticated));
  }

  String? _registrationValidationError() {
    if (state.fullName.trim().split(RegExp(r'\s+')).length < 2) {
      return 'Please enter your full name.';
    }
    if (!_isValidEmail(state.email.trim())) {
      return 'Please enter a valid email address.';
    }
    if (state.password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (state.selectedRole == null) {
      return 'Please select your role.';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }
}
