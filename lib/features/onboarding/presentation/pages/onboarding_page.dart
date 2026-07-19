import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_logo.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../core/widgets/page_indicator.dart';
import '../../../../injection/injection.dart';
import '../bloc/onboarding_bloc.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const _slides = [
    (
      title: 'Centralized Opportunities',
      body: 'Grants, accelerators, and scholarships all in one searchable hub.',
    ),
    (
      title: 'Verified & Trusted',
      body: "We verify every listing so you don't waste time on scams.",
    ),
    (
      title: 'Never Miss Out',
      body: 'Get personalized matches and deadline reminders tailored to you.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(completeOnboarding: sl()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (prev, next) =>
          prev.pageIndex != next.pageIndex || prev.completed != next.completed,
      listener: (context, state) {
        if (state.completed) {
          context.go('/create-account');
          return;
        }
        if (_controller.hasClients &&
            (_controller.page?.round() ?? 0) != state.pageIndex) {
          _controller.animateToPage(
            state.pageIndex,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: OnboardingPage._slides.length,
                      onPageChanged: (index) {
                        context.read<OnboardingBloc>().add(
                          OnboardingPageChanged(index),
                        );
                      },
                      itemBuilder: (context, index) {
                        final slide = OnboardingPage._slides[index];
                        return Column(
                          children: [
                            const Spacer(flex: 2),
                            const FhLogo(size: 140),
                            const SizedBox(height: 40),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              slide.body,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                            ),
                            const Spacer(flex: 3),
                          ],
                        );
                      },
                    ),
                  ),
                  PageIndicator(
                    count: OnboardingPage._slides.length,
                    index: state.pageIndex,
                  ),
                  const SizedBox(height: 24),
                  FhPrimaryButton(
                    label: 'Next',
                    showTrailingChevron: true,
                    onPressed: () {
                      context.read<OnboardingBloc>().add(
                        const OnboardingNextPressed(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
