import '../../domain/entities/opportunity.dart';
import '../../domain/repositories/opportunity_repository.dart';
import '../datasources/opportunity_firestore_datasource.dart';
import '../utils/opportunity_search.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  OpportunityRepositoryImpl(this._dataSource);

  final OpportunityFirestoreDataSource _dataSource;

  List<Opportunity> _publicOnly(List<Opportunity> items) =>
      items.where((o) => o.isPublic).toList();

  @override
  Future<List<Opportunity>> getOpportunities({
    String? query,
    String? userId,
  }) async {
    final items = await _withSavedFlags(
      _publicOnly(await _dataSource.fetchAll()),
      userId,
    );
    if (query == null || query.trim().isEmpty) return items;
    return items.where((o) => OpportunitySearch.matches(o, query)).toList();
  }

  @override
  Future<List<Opportunity>> getByCreator({required String userId}) async {
    return _withSavedFlags(await _dataSource.fetchByCreator(userId), userId);
  }

  @override
  Future<List<Opportunity>> getPendingModeration() async {
    final all = await _dataSource.fetchAll();
    return all
        .where((o) => o.moderationStatus == ModerationStatus.pending)
        .toList();
  }

  @override
  Future<List<Opportunity>> getAllForAdmin() async {
    return _dataSource.fetchAll();
  }

  @override
  Future<List<Opportunity>> getRecommended({
    List<String> interests = const [],
    String? role,
    String? userId,
  }) async {
    final items = await _withSavedFlags(
      _publicOnly(await _dataSource.fetchAll()),
      userId,
    );
    if (items.isEmpty) return const [];

    final preferenceTokens = <String>{
      ...interests.map((e) => e.toLowerCase()),
      if (role != null && role.trim().isNotEmpty) role.toLowerCase(),
    };

    if (preferenceTokens.isEmpty) {
      return items.take(3).toList();
    }

    int score(Opportunity o) {
      var s = 0;
      for (final tag in o.tags) {
        final t = tag.toLowerCase();
        if (preferenceTokens.any((p) => t.contains(p) || p.contains(t))) {
          s += 2;
        }
      }
      final type = o.typeLabel.toLowerCase();
      if (preferenceTokens.any((p) => type.contains(p) || p.contains(type))) {
        s += 1;
      }
      if (role != null &&
          o.tags.any((t) => t.toLowerCase() == role.toLowerCase())) {
        s += 3;
      }
      return s;
    }

    final ranked = [...items]..sort((a, b) => score(b).compareTo(score(a)));
    final matched = ranked.where((o) => score(o) > 0).take(3).toList();
    if (matched.isNotEmpty) return matched;
    return ranked.take(3).toList();
  }

  @override
  Future<List<Opportunity>> getSaved({required String userId}) async {
    final savedIds = await _dataSource.fetchSavedIds(userId);
    if (savedIds.isEmpty) return const [];
    final all = _publicOnly(await _dataSource.fetchAll());
    return all
        .where((o) => savedIds.contains(o.id))
        .map((o) => o.copyWith(isSaved: true))
        .toList();
  }

  @override
  Future<void> toggleSaved(String id, {required String userId}) async {
    final savedIds = await _dataSource.fetchSavedIds(userId);
    final currentlySaved = savedIds.contains(id);
    await _dataSource.setSaved(
      userId: userId,
      opportunityId: id,
      saved: !currentlySaved,
    );
  }

  @override
  Future<Opportunity?> getById(
    String id, {
    String? userId,
    bool allowNonPublic = false,
  }) async {
    final item = await _dataSource.fetchById(id);
    if (item == null) return null;
    // Entrepreneurs only see admin-approved listings (deep links included).
    if (!item.isPublic && !allowNonPublic) return null;
    if (userId == null) return item;
    final savedIds = await _dataSource.fetchSavedIds(userId);
    return item.copyWith(isSaved: savedIds.contains(id));
  }

  @override
  Future<void> createOpportunity(Opportunity opportunity) =>
      _dataSource.create(opportunity);

  @override
  Future<void> updateOpportunity(Opportunity opportunity) =>
      _dataSource.update(opportunity);

  @override
  Future<void> deleteOpportunity(String id) => _dataSource.delete(id);

  @override
  Future<void> reviewOpportunity({
    required Opportunity opportunity,
    required ModerationStatus status,
    required String reviewerId,
    String note = '',
  }) {
    final updated = opportunity.copyWith(
      moderationStatus: status,
      isVerified: status == ModerationStatus.approved,
      moderationNote: note,
      reviewedBy: reviewerId,
      reviewedAt: DateTime.now(),
    );
    return _dataSource.update(updated);
  }

  Future<List<Opportunity>> _withSavedFlags(
    List<Opportunity> items,
    String? userId,
  ) async {
    if (userId == null || userId.isEmpty) return items;
    final savedIds = await _dataSource.fetchSavedIds(userId);
    return items
        .map((o) => o.copyWith(isSaved: savedIds.contains(o.id)))
        .toList();
  }
}
