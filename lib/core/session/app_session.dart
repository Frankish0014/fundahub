import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sync session flags for fast route guards (no network on tab switches).
class AppSession {
  AppSession(this._prefs, [FirebaseAuth? auth])
    : _auth = auth ?? FirebaseAuth.instance;

  static const _onboardingKey = 'onboarding_completed';

  final SharedPreferences _prefs;
  final FirebaseAuth _auth;

  /// Instant — uses Firebase Auth's in-memory current user.
  bool get isSignedIn => _auth.currentUser != null;

  /// Instant — SharedPreferences is already loaded in memory.
  bool get hasCompletedOnboarding =>
      _prefs.getBool(_onboardingKey) ?? false;
}
