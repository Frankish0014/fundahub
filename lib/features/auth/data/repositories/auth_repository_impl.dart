import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  Future<UserProfile?> getCurrentUser() => _local.getCurrentUser();

  @override
  Future<bool> hasCompletedOnboarding() => _local.hasCompletedOnboarding();

  @override
  Future<void> setOnboardingCompleted(bool value) =>
      _local.setOnboardingCompleted(value);

  @override
  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    // Password validated in presentation; Firebase Auth comes later.
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }
    return _local.saveUser(fullName: fullName, email: email, role: role);
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final existing = await _local.getCurrentUser();
    if (existing != null && existing.email == email) {
      return existing;
    }
    // Demo login creates a session for UI flow until Firebase is wired.
    return _local.saveUser(
      fullName: 'Andrew',
      email: email,
      role: 'Student Entrepreneur',
      interests: const ['Tech', 'Education', 'Seed Funding'],
    );
  }

  @override
  Future<UserProfile> updateInterests(List<String> interests) =>
      _local.updateInterests(interests);

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String role,
  }) async {
    final existing = await _local.getCurrentUser();
    if (existing == null) {
      throw StateError('No authenticated user');
    }
    return _local.saveUser(
      fullName: fullName,
      email: existing.email,
      role: role,
      interests: existing.interests,
    );
  }

  @override
  Future<void> logout() => _local.clearSession();
}
