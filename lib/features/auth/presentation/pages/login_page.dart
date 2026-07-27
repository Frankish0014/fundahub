import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../core/widgets/fh_text_field.dart';
import '../../../../injection/injection.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl.createAuthBloc(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, next) =>
          previous.status != next.status ||
          previous.errorMessage != next.errorMessage ||
          previous.infoMessage != next.infoMessage,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
          return;
        }
        final message = state.errorMessage ?? state.infoMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical -
                      56,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log In',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome back to FundaHub.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      FhTextField(
                        hintText: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => context.read<AuthBloc>().add(
                          AuthEmailChanged(value),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FhTextField(
                        hintText: 'Password',
                        obscureText: true,
                        onChanged: (value) => context.read<AuthBloc>().add(
                          AuthPasswordChanged(value),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => _showForgotPasswordDialog(
                                  context,
                                  state.email,
                                ),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const Spacer(),
                      FhPrimaryButton(
                        label: isLoading ? 'Please wait...' : 'Log In',
                        onPressed: isLoading
                            ? null
                            : () => context.read<AuthBloc>().add(
                                const AuthLoginSubmitted(),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => context.read<AuthBloc>().add(
                                  const AuthGoogleSubmitted(),
                                ),
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Text('Continue with Google'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go('/create-account'),
                          child: const Text(
                            "Don't have an account? Create one",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showForgotPasswordDialog(
    BuildContext context,
    String currentEmail,
  ) async {
    var enteredEmail = currentEmail;

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset password'),
          content: TextFormField(
            initialValue: currentEmail,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            onChanged: (value) {
              enteredEmail = value;
            },
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'name@example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Send reset email'),
            ),
          ],
        );
      },
    );

    if (shouldSend == true && context.mounted) {
      context.read<AuthBloc>().add(AuthPasswordResetRequested(enteredEmail));
    }
  }
}
