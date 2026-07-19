import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class FundaHubApp extends StatefulWidget {
  const FundaHubApp({super.key});

  @override
  State<FundaHubApp> createState() => _FundaHubAppState();
}

class _FundaHubAppState extends State<FundaHubApp> {
  late final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FundaHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
