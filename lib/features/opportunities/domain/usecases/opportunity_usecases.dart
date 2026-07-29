import '../entities/opportunity.dart';
import '../repositories/opportunity_repository.dart';

class GetOpportunities {
  const GetOpportunities(this._repository);
  final OpportunityRepository _repository;
  Future<List<Opportunity>> call({String? query, String? userId}) =>
      _repository.getOpportunities(query: query, userId: userId);
}

class GetRecommendedOpportunities {
  const GetRecommendedOpportunities(this._repository);
  final OpportunityRepository _repository;
  Future<List<Opportunity>> call({
    List<String> interests = const [],
    String? role,
    String? userId,
  }) => _repository.getRecommended(
    interests: interests,
    role: role,
    userId: userId,
  );
}

class GetSavedOpportunities {
  const GetSavedOpportunities(this._repository);
  final OpportunityRepository _repository;
  Future<List<Opportunity>> call({required String userId}) =>
      _repository.getSaved(userId: userId);
}

class GetMyOpportunities {
  const GetMyOpportunities(this._repository);
  final OpportunityRepository _repository;
  Future<List<Opportunity>> call({required String userId}) =>
      _repository.getByCreator(userId: userId);
}

class ToggleSavedOpportunity {
  const ToggleSavedOpportunity(this._repository);
  final OpportunityRepository _repository;
  Future<void> call(String id, {required String userId}) =>
      _repository.toggleSaved(id, userId: userId);
}

class GetOpportunityById {
  const GetOpportunityById(this._repository);
  final OpportunityRepository _repository;
  Future<Opportunity?> call(
    String id, {
    String? userId,
    bool allowNonPublic = false,
  }) => _repository.getById(id, userId: userId, allowNonPublic: allowNonPublic);
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

class GetPendingOpportunities {
  const GetPendingOpportunities(this._repository);
  final OpportunityRepository _repository;
  Future<List<Opportunity>> call() => _repository.getPendingModeration();
}

class GetAllOpportunitiesForAdmin {
  const GetAllOpportunitiesForAdmin(this._repository);
  final OpportunityRepository _repository;
  Future<List<Opportunity>> call() => _repository.getAllForAdmin();
}

class ReviewOpportunity {
  const ReviewOpportunity(this._repository);
  final OpportunityRepository _repository;
  Future<void> call({
    required Opportunity opportunity,
    required ModerationStatus status,
    required String reviewerId,
    String note = '',
  }) => _repository.reviewOpportunity(
    opportunity: opportunity,
    status: status,
    reviewerId: reviewerId,
    note: note,
  );
}
