import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/locale/app_locale_controller.dart';
import 'core/locale/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_appearance_controller.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'injection/injection.dart';

class FundaHubApp extends StatefulWidget {
  const FundaHubApp({super.key});

  @override
  State<FundaHubApp> createState() => _FundaHubAppState();
}

class _FundaHubAppState extends State<FundaHubApp> {
  late final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    final localeController = sl<AppLocaleController>();
    final appearance = sl<AppAppearanceController>();

    return ListenableBuilder(
      listenable: Listenable.merge([localeController, appearance]),
      builder: (context, _) {
        // Bind before MaterialApp so the first frame already matches themeMode.
        AppColors.bind(AppColors.resolveBrightness(appearance.themeMode));
        return MaterialApp.router(
          title: 'FundaHub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(compact: appearance.compactMode),
          darkTheme: AppTheme.dark(compact: appearance.compactMode),
          themeMode: appearance.themeMode,
          locale: localeController.materialLocale,
          supportedLocales: const [Locale('en'), Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supported) {
            if (locale == null) return const Locale('en');
            for (final candidate in supported) {
              if (candidate.languageCode == locale.languageCode) {
                return candidate;
              }
            }
            return const Locale('en');
          },
          builder: (context, child) {
            AppColors.bind(Theme.of(context).colorScheme.brightness);
            return AppStringsScope(
              strings: AppStrings(localeController.languageCode),
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(appearance.textScale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
          routerConfig: _router,
        );
      },
    );
  }
}
