import '../entities/opportunity_application.dart';

abstract class ApplicationRepository {
  Future<void> submitApplication(OpportunityApplication application);

  Future<OpportunityApplication?> getById(String id);

  Future<OpportunityApplication?> getForApplicantOnOpportunity({
    required String opportunityId,
    required String applicantId,
  });

  Future<List<OpportunityApplication>> getForApplicant(String applicantId);

  Future<List<OpportunityApplication>> getForProvider(String providerId);

  Future<List<OpportunityApplication>> getForOpportunity(String opportunityId);

  Future<List<OpportunityApplication>> getAll();

  Future<void> reviewApplication({
    required String applicationId,
    required ApplicationStatus status,
    required String reviewerId,
    String reviewerNote = '',
  });
}
