import '../entities/training_path.dart';
import '../entities/training_resource.dart';
import '../repositories/resources_repository.dart';

class GetTrainingPaths {
  const GetTrainingPaths(this._repository);

  final ResourcesRepository _repository;

  Future<List<TrainingPath>> call() => _repository.getPaths();
}

class GetTrainingResources {
  const GetTrainingResources(this._repository);

  final ResourcesRepository _repository;

  Future<List<TrainingResource>> call({String? query}) =>
      _repository.getResources(query: query);
}

class GetTrainingResource {
  const GetTrainingResource(this._repository);

  final ResourcesRepository _repository;

  Future<TrainingResource?> call(String id) => _repository.getResource(id);
}
