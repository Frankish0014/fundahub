import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fundahub/core/locale/app_locale_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to English when no preference or initial code is set', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = AppLocaleController(prefs);

    expect(controller.languageCode, 'en');
    expect(controller.materialLocale.languageCode, 'en');
  });

  test('an unsupported initial code falls back to English', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = AppLocaleController(prefs, 'de');

    expect(controller.languageCode, 'en');
  });

  test('setLanguage persists the choice and notifies listeners', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = AppLocaleController(prefs);
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.setLanguage('fr');

    expect(controller.languageCode, 'fr');
    expect(controller.materialLocale.languageCode, 'fr');
    expect(notified, 1);
    expect(prefs.getString('pref_language_code'), 'fr');
  });

  test('Kinyarwanda is stored as-is but falls back to English for MaterialLocalizations', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = AppLocaleController(prefs);

    await controller.setLanguage('rw');

    expect(controller.languageCode, 'rw');
    expect(controller.materialLocale.languageCode, 'en');
  });

  test('the language preference survives a simulated app restart', () async {
    final prefs = await SharedPreferences.getInstance();
    final before = AppLocaleController(prefs);
    await before.setLanguage('fr');

    final after = AppLocaleController(prefs);

    expect(after.languageCode, 'fr');
  });
}
