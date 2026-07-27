import '../../domain/entities/gov_programme.dart';
import '../../domain/repositories/government_repository.dart';
import '../datasources/government_remote_datasource.dart';

class GovernmentRepositoryImpl implements GovernmentRepository {
  GovernmentRepositoryImpl(this._dataSource);

  final GovernmentRemoteDataSource _dataSource;

  @override
  Future<List<GovProgramme>> getProgrammes({String? category}) =>
      _dataSource.fetchProgrammes(category: category);

  @override
  Future<GovProgramme?> getProgramme(String id) =>
      _dataSource.fetchProgramme(id);
}
