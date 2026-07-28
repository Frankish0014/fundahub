import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'injection/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? startupError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 20));
    await initDependencies().timeout(const Duration(seconds: 20));
  } catch (error, stack) {
    startupError = error;
    debugPrint('FundaHub startup failed: $error\n$stack');
  }

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
    ),
  );

  if (startupError != null) {
    runApp(_StartupErrorApp(error: startupError));
    return;
  }

  runApp(const FundaHubApp());
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FundaHub could not start',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chrome could not load Firebase (gstatic.com). '
                  'Hard-refresh the page (Ctrl+Shift+R), disable VPN/ad-block '
                  'for localhost, or run again with a local web resources CDN.',
                ),
                const SizedBox(height: 16),
                SelectableText(
                  '$error',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Full restart requires re-running main; ask user to refresh.
                  },
                  child: const Text('Refresh the browser tab'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
