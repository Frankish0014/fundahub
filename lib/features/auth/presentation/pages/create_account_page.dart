import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, n) => p.status != n.status,
      listener: (context, state) {
        if (state.status == AuthStatus.registered) {
          context.go('/tailor');
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join FundaHub to find your next opportunity.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FhTextField(
                    hintText: 'Full Name',
                    onChanged: (v) =>
                        context.read<AuthBloc>().add(AuthFullNameChanged(v)),
                  ),
                  const SizedBox(height: 14),
                  FhTextField(
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) =>
                        context.read<AuthBloc>().add(AuthEmailChanged(v)),
                  ),
                  const SizedBox(height: 14),
                  FhTextField(
                    hintText: 'Password',
                    obscureText: true,
                    onChanged: (v) =>
                        context.read<AuthBloc>().add(AuthPasswordChanged(v)),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'I am a...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...AppConstants.entrepreneurRoles.map((role) {
                    final selected = state.selectedRole == role;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.read<AuthBloc>().add(
                          AuthRoleSelected(role),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.mintSoft
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            role,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  FhPrimaryButton(
                    label: state.status == AuthStatus.loading
                        ? 'Please wait...'
                        : 'Continue',
                    onPressed: state.status == AuthStatus.loading
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
        );
      },
    );
  }
}
