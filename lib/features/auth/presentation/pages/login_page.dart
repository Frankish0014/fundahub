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
      listenWhen: (p, n) => p.status != n.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log In',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                  const Spacer(),
                  FhPrimaryButton(
                    label: state.status == AuthStatus.loading
                        ? 'Please wait...'
                        : 'Log In',
                    onPressed: state.status == AuthStatus.loading
                        ? null
                        : () => context.read<AuthBloc>().add(
                            const AuthLoginSubmitted(),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/create-account'),
                      child: const Text("Don't have an account? Create one"),
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
