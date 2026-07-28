import '../entities/training_path.dart';
import '../entities/training_resource.dart';

abstract class ResourcesRepository {
  Future<List<TrainingPath>> getPaths();

  /// Returns training resources. [query] optionally filters by title/category.
  Future<List<TrainingResource>> getResources({String? query});

  Future<TrainingResource?> getResource(String id);
}
