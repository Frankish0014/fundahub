import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_logo.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../core/widgets/fh_text_field.dart';
import '../../../../injection/injection.dart';
import '../bloc/auth_bloc.dart';

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl.createAuthBloc(),
      child: const _CreateAccountView(),
    );
  }
}

class _CreateAccountView extends StatelessWidget {
  const _CreateAccountView();

  Widget _roleChip(
    BuildContext context, {
    required String role,
    required bool selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.read<AuthBloc>().add(AuthRoleSelected(role)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.mintSoft : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  role,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, next) =>
          previous.status != next.status ||
          previous.errorMessage != next.errorMessage ||
          previous.infoMessage != next.infoMessage,
      listener: (context, state) {
        if (state.status == AuthStatus.registered) {
          final message = state.infoMessage;
          if (message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
          context.go('/tailor');
          return;
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final loading = state.status == AuthStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Positioned(
                top: -90,
                left: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mint.withValues(alpha: 0.5),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FhLogo(size: 44),
                      const SizedBox(height: 22),
                      Text(
                        'Create Account',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join FundaHub and unlock verified opportunities made for young founders.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            FhTextField(
                              hintText: 'Full Name',
                              prefixIcon: Icons.person_outline_rounded,
                              onChanged: (v) => context.read<AuthBloc>().add(
                                AuthFullNameChanged(v),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FhTextField(
                              hintText: 'Email Address',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.mail_outline_rounded,
                              onChanged: (v) => context.read<AuthBloc>().add(
                                AuthEmailChanged(v),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FhTextField(
                              hintText: 'Password',
                              obscureText: true,
                              prefixIcon: Icons.lock_outline_rounded,
                              onChanged: (v) => context.read<AuthBloc>().add(
                                AuthPasswordChanged(v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'I am a...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Entrepreneurs',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...AppConstants.entrepreneurRoles.map(
                        (role) => _roleChip(
                          context,
                          role: role,
                          selected: state.selectedRole == role,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Opportunity providers',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...AppConstants.providerRoles.map(
                        (role) => _roleChip(
                          context,
                          role: role,
                          selected: state.selectedRole == role,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FhPrimaryButton(
                        label: loading ? 'Please wait...' : 'Continue',
                        onPressed: loading
                            ? null
                            : () => context.read<AuthBloc>().add(
                                const AuthRegisterSubmitted(),
                              ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Already have an account? Log In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
