import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_profile.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingKey = 'onboarding_completed';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';
  static const _userInterestsKey = 'user_interests';
  static const _loggedInKey = 'logged_in';

  Future<bool> hasCompletedOnboarding() async =>
      _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_onboardingKey, value);
  }

  Future<UserProfile?> getCurrentUser() async {
    final loggedIn = _prefs.getBool(_loggedInKey) ?? false;
    if (!loggedIn) return null;
    final name = _prefs.getString(_userNameKey);
    final email = _prefs.getString(_userEmailKey);
    final role = _prefs.getString(_userRoleKey);
    if (name == null || email == null || role == null) return null;
    return UserProfile(
      id: 'local-user',
      fullName: name,
      email: email,
      role: role,
      interests: _prefs.getStringList(_userInterestsKey) ?? const [],
    );
  }

  Future<UserProfile> saveUser({
    required String fullName,
    required String email,
    required String role,
    List<String> interests = const [],
  }) async {
    await _prefs.setBool(_loggedInKey, true);
    await _prefs.setString(_userNameKey, fullName);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userRoleKey, role);
    await _prefs.setStringList(_userInterestsKey, interests);
    return UserProfile(
      id: 'local-user',
      fullName: fullName,
      email: email,
      role: role,
      interests: interests,
    );
  }

  Future<UserProfile> updateInterests(List<String> interests) async {
    await _prefs.setStringList(_userInterestsKey, interests);
    final user = await getCurrentUser();
    if (user == null) {
      throw StateError('No authenticated user');
    }
    return user.copyWith(interests: interests);
  }

  Future<void> clearSession() async {
    await _prefs.setBool(_loggedInKey, false);
  }
}
