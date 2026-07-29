import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_logo.dart';
import '../../../../core/widgets/fh_primary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.brand,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        const FhLogo(variant: FhLogoVariant.splash, size: 96),
                        const SizedBox(height: 28),
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppConstants.tagline,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.onPrimary.withValues(
                                  alpha: 0.9,
                                ),
                                height: 1.4,
                              ),
                        ),
                        const Spacer(flex: 3),
                        FhPrimaryButton(
                          label: s.getStarted,
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primaryDark,
                          onPressed: () => context.go('/onboarding'),
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            s.logIn,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
