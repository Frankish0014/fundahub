import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAppearanceController extends ChangeNotifier {
  AppAppearanceController(this._prefs)
    : _themeMode = _parseThemeMode(_prefs.getString(_themeKey)),
      _textScale = _prefs.getDouble(_textScaleKey) ?? 1.0,
      _compactMode = _prefs.getBool(_compactKey) ?? false;

  static const _themeKey = 'pref_theme_mode';
  static const _textScaleKey = 'pref_text_scale';
  static const _compactKey = 'pref_compact_mode';

  final SharedPreferences _prefs;

  ThemeMode _themeMode;
  double _textScale;
  bool _compactMode;

  ThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;
  bool get compactMode => _compactMode;

  String themeLabelFor({
    required String light,
    required String dark,
    required String system,
  }) {
    switch (_themeMode) {
      case ThemeMode.light:
        return light;
      case ThemeMode.dark:
        return dark;
      case ThemeMode.system:
        return system;
    }
  }

  String textSizeLabelFor({
    required String small,
    required String defaults,
    required String large,
  }) {
    if (_textScale >= 1.2) return large;
    if (_textScale <= 0.95) return small;
    return defaults;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  Future<void> setTextScale(double scale) async {
    final clamped = scale.clamp(0.9, 1.3);
    if (_textScale == clamped) return;
    _textScale = clamped;
    await _prefs.setDouble(_textScaleKey, _textScale);
    notifyListeners();
  }

  Future<void> setCompactMode(bool enabled) async {
    if (_compactMode == enabled) return;
    _compactMode = enabled;
    await _prefs.setBool(_compactKey, enabled);
    notifyListeners();
  }

  static ThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }
}
