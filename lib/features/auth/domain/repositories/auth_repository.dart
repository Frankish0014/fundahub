import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();

  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });

  Future<UserProfile> login({required String email, required String password});

  Future<UserProfile> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserProfile> updateProfile({
    required String fullName,
    required String role,
    String? bio,
    String? photoUrl,
    String? language,
  });

  Future<UserProfile> updateInterests(List<String> interests);

  Future<UserProfile> uploadProfilePhoto({
    required List<int> bytes,
    required String fileName,
  });

  Future<void> logout();

  Future<bool> hasCompletedOnboarding();

  Future<void> setOnboardingCompleted(bool value);
}
