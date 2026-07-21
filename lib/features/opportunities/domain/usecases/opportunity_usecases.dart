import '../entities/opportunity.dart';
import '../repositories/opportunity_repository.dart';

class GetOpportunities {
  const GetOpportunities(this._repository);
  final OpportunityRepository _repository;
  Future<List<Opportunity>> call({String? query}) =>
      _repository.getOpportunities(query: query);
}

class GetRecommendedOpportunities {
  const GetRecommendedOpportunities(this._repository);
  final OpportunityRepository _repository;
  Future<List<Opportunity>> call() => _repository.getRecommended();
}

class GetSavedOpportunities {
  const GetSavedOpportunities(this._repository);
  final OpportunityRepository _repository;
  Future<List<Opportunity>> call() => _repository.getSaved();
}

class ToggleSavedOpportunity {
  const ToggleSavedOpportunity(this._repository);
  final OpportunityRepository _repository;
  Future<void> call(String id) => _repository.toggleSaved(id);
}

class GetOpportunityById {
  const GetOpportunityById(this._repository);
  final OpportunityRepository _repository;
  Future<Opportunity?> call(String id) => _repository.getById(id);
}

class CreateOpportunity {
  const CreateOpportunity(this._repository);
  final OpportunityRepository _repository;
  Future<void> call(Opportunity opportunity) =>
      _repository.createOpportunity(opportunity);
}

class UpdateOpportunity {
  const UpdateOpportunity(this._repository);
  final OpportunityRepository _repository;
  Future<void> call(Opportunity opportunity) =>
      _repository.updateOpportunity(opportunity);
}

class DeleteOpportunity {
  const DeleteOpportunity(this._repository);
  final OpportunityRepository _repository;
  Future<void> call(String id) => _repository.deleteOpportunity(id);
}
