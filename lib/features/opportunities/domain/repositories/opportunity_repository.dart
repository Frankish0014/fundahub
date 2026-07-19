import '../entities/opportunity.dart';

abstract class OpportunityRepository {
  Future<List<Opportunity>> getOpportunities({String? query});
  Future<List<Opportunity>> getRecommended();
  Future<List<Opportunity>> getSaved();
  Future<void> toggleSaved(String id);
}
