import '../../domain/entities/opportunity.dart';
import '../../domain/repositories/opportunity_repository.dart';
import '../datasources/opportunity_remote_datasource.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  OpportunityRepositoryImpl(this._dataSource);

  final OpportunityMockDataSource _dataSource;

  @override
  Future<List<Opportunity>> getOpportunities({String? query}) async {
    final items = await _dataSource.fetchAll();
    if (query == null || query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items
        .where(
          (o) =>
              o.title.toLowerCase().contains(q) ||
              o.organization.toLowerCase().contains(q) ||
              o.tags.any((t) => t.toLowerCase().contains(q)),
        )
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
    final index = _dataSource.mutableItems.indexWhere((o) => o.id == id);
    if (index == -1) return;
    final current = _dataSource.mutableItems[index];
    _dataSource.mutableItems[index] = current.copyWith(
      isSaved: !current.isSaved,
    );
  }
}
