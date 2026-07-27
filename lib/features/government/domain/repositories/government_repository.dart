import '../entities/gov_programme.dart';

abstract class GovernmentRepository {
  /// Returns government programmes. [category] optionally filters by bucket
  /// (e.g. "Agriculture"); "All Programs" or null returns everything.
  Future<List<GovProgramme>> getProgrammes({String? category});

  Future<GovProgramme?> getProgramme(String id);
}
