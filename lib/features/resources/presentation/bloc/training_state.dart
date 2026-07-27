part of 'training_bloc.dart';

enum TrainingStatus { initial, loading, success, failure }

class TrainingState extends Equatable {
  const TrainingState({
    this.status = TrainingStatus.initial,
    this.paths = const [],
    this.resources = const [],
    this.errorMessage,
  });

  final TrainingStatus status;
  final List<TrainingPath> paths;
  final List<TrainingResource> resources;
  final String? errorMessage;

  TrainingState copyWith({
    TrainingStatus? status,
    List<TrainingPath>? paths,
    List<TrainingResource>? resources,
    String? errorMessage,
  }) {
    return TrainingState(
      status: status ?? this.status,
      paths: paths ?? this.paths,
      resources: resources ?? this.resources,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, paths, resources, errorMessage];
}
