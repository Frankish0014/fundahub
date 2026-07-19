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
    on<AuthInterestsSubmitted>(_onInterestsSubmitted);
    on<AuthInterestsSkipped>(_onInterestsSkipped);
  }

  final RegisterUser registerUser;
  final LoginUser loginUser;
  final UpdateUserInterests updateUserInterests;
  final GetCurrentUser getCurrentUser;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final user = await getCurrentUser();
    if (user != null) {
      emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    }
  }

  void _onFullNameChanged(AuthFullNameChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(fullName: event.value, clearError: true));
  }

  void _onEmailChanged(AuthEmailChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(email: event.value, clearError: true));
  }

  void _onPasswordChanged(AuthPasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(password: event.value, clearError: true));
  }

  void _onRoleSelected(AuthRoleSelected event, Emitter<AuthState> emit) {
    emit(state.copyWith(selectedRole: event.role, clearError: true));
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
    if (state.fullName.trim().isEmpty ||
        state.email.trim().isEmpty ||
        state.password.isEmpty ||
        state.selectedRole == null) {
      emit(state.copyWith(errorMessage: 'Please complete all fields.'));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await registerUser(
        fullName: state.fullName.trim(),
        email: state.email.trim(),
        password: state.password,
        role: state.selectedRole!,
      );
      emit(state.copyWith(user: user, status: AuthStatus.registered));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.email.trim().isEmpty || state.password.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter email and password.'));
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await loginUser(
        email: state.email.trim(),
        password: state.password,
      );
      emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onInterestsSubmitted(
    AuthInterestsSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await updateUserInterests(state.selectedInterests);
      emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onInterestsSkipped(
    AuthInterestsSkipped event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticated));
  }
}
