import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/auth_usecases.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({required this.completeOnboarding})
    : super(const OnboardingState()) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingFinished>(_onFinished);
  }

  final CompleteOnboarding completeOnboarding;

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(pageIndex: event.index));
  }

  Future<void> _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state.pageIndex >= 2) {
      await completeOnboarding();
      emit(state.copyWith(completed: true));
      return;
    }
    emit(state.copyWith(pageIndex: state.pageIndex + 1));
  }

  Future<void> _onFinished(
    OnboardingFinished event,
    Emitter<OnboardingState> emit,
  ) async {
    await completeOnboarding();
    emit(state.copyWith(completed: true));
  }
}
