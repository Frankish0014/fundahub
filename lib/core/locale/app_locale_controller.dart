import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and broadcasts the user's language preference (en / fr / rw).
class AppLocaleController extends ChangeNotifier {
  AppLocaleController(this._prefs, [String? initialCode])
    : _languageCode = _normalize(
        _prefs.getString(_prefsKey) ?? initialCode ?? 'en',
      );

  static const _prefsKey = 'pref_language_code';

  final SharedPreferences _prefs;
  String _languageCode;

  String get languageCode => _languageCode;

  /// Locale for Material widgets. Kinyarwanda falls back to English because
  /// Flutter has no built-in MaterialLocalizations for `rw`.
  Locale get materialLocale {
    switch (_languageCode) {
      case 'fr':
        return const Locale('fr');
      case 'en':
      case 'rw':
      default:
        return const Locale('en');
    }
  }

  Future<void> setLanguage(String code) async {
    final normalized = _normalize(code);
    if (_languageCode == normalized) return;
    _languageCode = normalized;
    await _prefs.setString(_prefsKey, normalized);
    notifyListeners();
  }

  static String _normalize(String code) {
    final value = code.trim().toLowerCase();
    if (value == 'fr' || value == 'rw' || value == 'en') return value;
    return 'en';
  }
}
