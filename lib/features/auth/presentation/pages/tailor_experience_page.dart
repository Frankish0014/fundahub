import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../injection/injection.dart';
import '../bloc/auth_bloc.dart';

class TailorExperiencePage extends StatelessWidget {
  const TailorExperiencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl.createAuthBloc(),
      child: const _TailorView(),
    );
  }
}

class _TailorView extends StatelessWidget {
  const _TailorView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, n) => p.status != n.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tailor your experience',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Select tags to help our AI match you with the right opportunities.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AppConstants.interestTags.map((tag) {
                          final selected = state.selectedInterests.contains(
                            tag,
                          );
                          return ChoiceChip(
                            label: Text(tag),
                            selected: selected,
                            onSelected: (_) => context.read<AuthBloc>().add(
                              AuthInterestToggled(tag),
                            ),
                            selectedColor: AppColors.interestChipBg,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.interestChipText
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.35)
                                  : AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  FhPrimaryButton(
                    label: 'Finish Setup',
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthInterestsSubmitted(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => context.read<AuthBloc>().add(
                        const AuthInterestsSkipped(),
                      ),
                      child: Text(
                        'Skip for now',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
