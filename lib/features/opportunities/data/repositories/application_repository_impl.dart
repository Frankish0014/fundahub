import '../../domain/entities/opportunity_application.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_firestore_datasource.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  ApplicationRepositoryImpl(this._dataSource);

  final ApplicationFirestoreDataSource _dataSource;

  @override
  Future<void> submitApplication(OpportunityApplication application) =>
      _dataSource.create(application);

  @override
  Future<OpportunityApplication?> getById(String id) =>
      _dataSource.fetchById(id);

  @override
  Future<OpportunityApplication?> getForApplicantOnOpportunity({
    required String opportunityId,
    required String applicantId,
  }) => _dataSource.fetchForApplicant(
    opportunityId: opportunityId,
    applicantId: applicantId,
  );

  @override
  Future<List<OpportunityApplication>> getForApplicant(String applicantId) =>
      _dataSource.fetchForApplicantAll(applicantId);

  @override
  Future<List<OpportunityApplication>> getForProvider(String providerId) =>
      _dataSource.fetchForProvider(providerId);

  @override
  Future<List<OpportunityApplication>> getForOpportunity(
    String opportunityId,
  ) => _dataSource.fetchForOpportunity(opportunityId);

  @override
  Future<void> reviewApplication({
    required String applicationId,
    required ApplicationStatus status,
    required String reviewerId,
    String reviewerNote = '',
  }) => _dataSource.updateStatus(
    applicationId: applicationId,
    status: status,
    reviewerId: reviewerId,
    reviewerNote: reviewerNote,
  );
}
