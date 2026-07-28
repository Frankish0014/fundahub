import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_profile.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingKey = 'onboarding_completed';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';
  static const _userInterestsKey = 'user_interests';
  static const _emailVerifiedKey = 'email_verified';

  Future<bool> hasCompletedOnboarding() async =>
      _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_onboardingKey, value);
  }

  Future<UserProfile?> getCurrentUser() async {
    final id = _prefs.getString(_userIdKey);
    final name = _prefs.getString(_userNameKey);
    final email = _prefs.getString(_userEmailKey);
    final role = _prefs.getString(_userRoleKey);
    if (id == null || name == null || email == null || role == null) {
      return null;
    }
    return UserProfile(
      id: id,
      fullName: name,
      email: email,
      role: role,
      interests: _prefs.getStringList(_userInterestsKey) ?? const [],
      emailVerified: _prefs.getBool(_emailVerifiedKey) ?? false,
    );
  }

  Future<UserProfile> saveUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
    List<String> interests = const [],
    bool emailVerified = false,
  }) async {
    await _prefs.setString(_userIdKey, id);
    await _prefs.setString(_userNameKey, fullName);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userRoleKey, role);
    await _prefs.setStringList(_userInterestsKey, interests);
    await _prefs.setBool(_emailVerifiedKey, emailVerified);
    return UserProfile(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      interests: interests,
      emailVerified: emailVerified,
    );
  }

  Future<UserProfile> updateInterests(List<String> interests) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw StateError('No authenticated user');
    }
    return saveUser(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      interests: interests,
      emailVerified: user.emailVerified,
    );
  }

  Future<void> clearSession() {
    // Firebase Auth owns the real authenticated session. The non-sensitive
    // profile cache remains so role and interests survive a later login by the
    // same UID. AuthRepository always checks Firebase before returning it.
    return Future<void>.value();
  }
}
