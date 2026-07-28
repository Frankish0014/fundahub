part of 'training_bloc.dart';

sealed class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object?> get props => [];
}

class TrainingStarted extends TrainingEvent {
  const TrainingStarted();
}
