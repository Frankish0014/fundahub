import '../entities/opportunity.dart';

abstract class OpportunityRepository {
  Future<List<Opportunity>> getOpportunities({String? query, String? userId});
  Future<List<Opportunity>> getRecommended({
    List<String> interests = const [],
    String? role,
    String? userId,
  });
  Future<List<Opportunity>> getSaved({required String userId});
  Future<List<Opportunity>> getByCreator({required String userId});
  Future<List<Opportunity>> getPendingModeration();
  Future<List<Opportunity>> getAllForAdmin();
  Future<void> toggleSaved(String id, {required String userId});
  Future<Opportunity?> getById(
    String id, {
    String? userId,
    bool allowNonPublic = false,
  });
  Future<void> createOpportunity(Opportunity opportunity);
  Future<void> updateOpportunity(Opportunity opportunity);
  Future<void> deleteOpportunity(String id);
  Future<void> reviewOpportunity({
    required Opportunity opportunity,
    required ModerationStatus status,
    required String reviewerId,
    String note = '',
  });
}
