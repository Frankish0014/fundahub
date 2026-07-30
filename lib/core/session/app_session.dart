import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sync session flags for fast route guards (no network on tab switches).
class AppSession {
  AppSession(this._prefs, [this._auth]);

  static const _onboardingKey = 'onboarding_completed';

  final SharedPreferences _prefs;
  final FirebaseAuth? _auth;

  /// Instant — uses Firebase Auth's in-memory current user. Falls back to
  /// "not signed in" if no Firebase app is available (e.g. widget tests that
  /// don't call `Firebase.initializeApp()`), rather than throwing.
  bool get isSignedIn {
    try {
      return (_auth ?? FirebaseAuth.instance).currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Instant — SharedPreferences is already loaded in memory.
  bool get hasCompletedOnboarding => _prefs.getBool(_onboardingKey) ?? false;
}
