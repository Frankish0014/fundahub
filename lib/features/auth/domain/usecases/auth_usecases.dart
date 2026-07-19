import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<UserProfile> call({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) {
    return _repository.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }
}

class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<UserProfile> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

class UpdateUserInterests {
  const UpdateUserInterests(this._repository);

  final AuthRepository _repository;

  Future<UserProfile> call(List<String> interests) =>
      _repository.updateInterests(interests);
}

class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<UserProfile?> call() => _repository.getCurrentUser();
}

class CompleteOnboarding {
  const CompleteOnboarding(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.setOnboardingCompleted(true);
}

class HasCompletedOnboarding {
  const HasCompletedOnboarding(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.hasCompletedOnboarding();
}
