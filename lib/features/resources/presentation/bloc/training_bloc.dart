import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/training_path.dart';
import '../../domain/entities/training_resource.dart';
import '../../domain/usecases/resources_usecases.dart';

part 'training_event.dart';
part 'training_state.dart';

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  TrainingBloc({
    required this.getTrainingPaths,
    required this.getTrainingResources,
  }) : super(const TrainingState()) {
    on<TrainingStarted>(_onStarted);
  }

  final GetTrainingPaths getTrainingPaths;
  final GetTrainingResources getTrainingResources;

  Future<void> _onStarted(
    TrainingStarted event,
    Emitter<TrainingState> emit,
  ) async {
    emit(state.copyWith(status: TrainingStatus.loading));
    try {
      final paths = await getTrainingPaths();
      final resources = await getTrainingResources();
      emit(
        state.copyWith(
          status: TrainingStatus.success,
          paths: paths,
          resources: resources,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TrainingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
