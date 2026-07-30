import '../entities/opportunity_application.dart';
import '../repositories/application_repository.dart';

class SubmitApplication {
  const SubmitApplication(this._repository);
  final ApplicationRepository _repository;
  Future<void> call(OpportunityApplication application) =>
      _repository.submitApplication(application);
}

class GetMyApplicationForOpportunity {
  const GetMyApplicationForOpportunity(this._repository);
  final ApplicationRepository _repository;
  Future<OpportunityApplication?> call({
    required String opportunityId,
    required String applicantId,
  }) => _repository.getForApplicantOnOpportunity(
    opportunityId: opportunityId,
    applicantId: applicantId,
  );
}

class GetProviderApplications {
  const GetProviderApplications(this._repository);
  final ApplicationRepository _repository;
  Future<List<OpportunityApplication>> call({required String providerId}) =>
      _repository.getForProvider(providerId);
}

class GetOpportunityApplications {
  const GetOpportunityApplications(this._repository);
  final ApplicationRepository _repository;
  Future<List<OpportunityApplication>> call({required String opportunityId}) =>
      _repository.getForOpportunity(opportunityId);
}

class GetApplicationById {
  const GetApplicationById(this._repository);
  final ApplicationRepository _repository;
  Future<OpportunityApplication?> call(String id) => _repository.getById(id);
}

class ReviewApplication {
  const ReviewApplication(this._repository);
  final ApplicationRepository _repository;
  Future<void> call({
    required String applicationId,
    required ApplicationStatus status,
    required String reviewerId,
    String reviewerNote = '',
  }) => _repository.reviewApplication(
    applicationId: applicationId,
    status: status,
    reviewerId: reviewerId,
    reviewerNote: reviewerNote,
  );
}
