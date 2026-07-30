import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fundahub/core/theme/app_appearance_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to light theme, 1.0 text scale, and compact mode off', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = AppAppearanceController(prefs);

    expect(controller.themeMode, ThemeMode.light);
    expect(controller.textScale, 1.0);
    expect(controller.compactMode, isFalse);
  });

  test('setThemeMode persists to SharedPreferences and notifies listeners', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = AppAppearanceController(prefs);
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.setThemeMode(ThemeMode.dark);

    expect(controller.themeMode, ThemeMode.dark);
    expect(notified, 1);
    expect(prefs.getString('pref_theme_mode'), 'dark');
  });

  test('setTextScale clamps to the 0.9-1.3 range and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = AppAppearanceController(prefs);

    await controller.setTextScale(5.0);

    expect(controller.textScale, 1.3);
    expect(prefs.getDouble('pref_text_scale'), 1.3);
  });

  test('setCompactMode persists to SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = AppAppearanceController(prefs);

    await controller.setCompactMode(true);

    expect(controller.compactMode, isTrue);
    expect(prefs.getBool('pref_compact_mode'), isTrue);
  });

  test('all three preferences survive a simulated app restart', () async {
    final prefs = await SharedPreferences.getInstance();
    final before = AppAppearanceController(prefs);
    await before.setThemeMode(ThemeMode.dark);
    await before.setTextScale(1.2);
    await before.setCompactMode(true);

    // Simulate relaunch: a fresh controller reading the same SharedPreferences.
    final after = AppAppearanceController(prefs);

    expect(after.themeMode, ThemeMode.dark);
    expect(after.textScale, 1.2);
    expect(after.compactMode, isTrue);
  });
}
