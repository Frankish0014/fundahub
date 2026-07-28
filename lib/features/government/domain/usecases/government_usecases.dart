import '../entities/gov_programme.dart';
import '../repositories/government_repository.dart';

class GetGovProgrammes {
  const GetGovProgrammes(this._repository);

  final GovernmentRepository _repository;

  Future<List<GovProgramme>> call({String? category}) =>
      _repository.getProgrammes(category: category);
}

class GetGovProgramme {
  const GetGovProgramme(this._repository);

  final GovernmentRepository _repository;

  Future<GovProgramme?> call(String id) => _repository.getProgramme(id);
}
