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
  static const _userBioKey = 'user_bio';
  static const _userPhotoKey = 'user_photo_url';
  static const _userLanguageKey = 'user_language';

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
      bio: _prefs.getString(_userBioKey) ?? '',
      photoUrl: _prefs.getString(_userPhotoKey),
      language: _prefs.getString(_userLanguageKey) ?? 'en',
    );
  }

  Future<UserProfile> saveUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
    List<String> interests = const [],
    bool emailVerified = false,
    String bio = '',
    String? photoUrl,
    String language = 'en',
  }) async {
    await _prefs.setString(_userIdKey, id);
    await _prefs.setString(_userNameKey, fullName);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userRoleKey, role);
    await _prefs.setStringList(_userInterestsKey, interests);
    await _prefs.setBool(_emailVerifiedKey, emailVerified);
    await _prefs.setString(_userBioKey, bio);
    await _prefs.setString(_userLanguageKey, language);
    if (photoUrl == null || photoUrl.isEmpty) {
      await _prefs.remove(_userPhotoKey);
    } else {
      await _prefs.setString(_userPhotoKey, photoUrl);
    }
    return UserProfile(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      interests: interests,
      emailVerified: emailVerified,
      bio: bio,
      photoUrl: photoUrl,
      language: language,
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
      bio: user.bio,
      photoUrl: user.photoUrl,
      language: user.language,
    );
  }

  Future<void> clearSession() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userRoleKey);
    await _prefs.remove(_userInterestsKey);
    await _prefs.remove(_emailVerifiedKey);
    await _prefs.remove(_userBioKey);
    await _prefs.remove(_userPhotoKey);
    await _prefs.remove(_userLanguageKey);
  }
}
