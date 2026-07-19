part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingPageChanged extends OnboardingEvent {
  const OnboardingPageChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

class OnboardingFinished extends OnboardingEvent {
  const OnboardingFinished();
}
