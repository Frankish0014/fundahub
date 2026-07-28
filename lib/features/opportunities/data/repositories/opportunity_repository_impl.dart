import '../../domain/entities/opportunity.dart';
import '../../domain/repositories/opportunity_repository.dart';
import '../datasources/opportunity_firestore_datasource.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  OpportunityRepositoryImpl(this._dataSource);

  final OpportunityFirestoreDataSource _dataSource;

  @override
  Future<List<Opportunity>> getOpportunities({String? query}) async {
    final items = await _dataSource.fetchAll();
    if (query == null || query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items
        .where((o) =>
            o.title.toLowerCase().contains(q) ||
            o.organization.toLowerCase().contains(q) ||
            o.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Future<List<Opportunity>> getRecommended() async {
    final items = await _dataSource.fetchAll();
    return items.take(3).toList();
  }

  @override
  Future<List<Opportunity>> getSaved() async {
    final items = await _dataSource.fetchAll();
    return items.where((o) => o.isSaved).toList();
  }

  @override
  Future<void> toggleSaved(String id) async {
    final current = await _dataSource.fetchById(id);
    if (current == null) return;
    await _dataSource.update(current.copyWith(isSaved: !current.isSaved));
  }

  @override
  Future<Opportunity?> getById(String id) => _dataSource.fetchById(id);

  @override
  Future<void> createOpportunity(Opportunity opportunity) =>
      _dataSource.create(opportunity);

  @override
  Future<void> updateOpportunity(Opportunity opportunity) =>
      _dataSource.update(opportunity);

  @override
  Future<void> deleteOpportunity(String id) => _dataSource.delete(id);
}
