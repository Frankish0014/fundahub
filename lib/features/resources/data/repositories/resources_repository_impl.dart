import '../../domain/entities/training_path.dart';
import '../../domain/entities/training_resource.dart';
import '../../domain/repositories/resources_repository.dart';
import '../datasources/resources_remote_datasource.dart';

class ResourcesRepositoryImpl implements ResourcesRepository {
  ResourcesRepositoryImpl(this._dataSource);

  final ResourcesRemoteDataSource _dataSource;

  @override
  Future<List<TrainingPath>> getPaths() => _dataSource.fetchPaths();

  @override
  Future<List<TrainingResource>> getResources({String? query}) =>
      _dataSource.fetchResources(query: query);

  @override
  Future<TrainingResource?> getResource(String id) =>
      _dataSource.fetchResource(id);
}
