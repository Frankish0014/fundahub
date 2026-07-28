import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  pending,
  underReview,
  granted,
  rejected,
  withdrawn,
}

class OpportunityApplication extends Equatable {
  const OpportunityApplication({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.providerId,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.businessName,
    required this.businessDescription,
    required this.location,
    required this.fundingRequested,
    required this.howFundsWillBeUsed,
    required this.teamSize,
    required this.yearsInOperation,
    required this.impactStatement,
    this.eligibilityConfirmed = false,
    this.status = ApplicationStatus.pending,
    this.reviewerNote = '',
    this.reviewedAt,
    this.reviewedBy,
    this.submittedAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String providerId;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String businessName;
  final String businessDescription;
  final String location;
  final String fundingRequested;
  final String howFundsWillBeUsed;
  final int teamSize;
  final int yearsInOperation;
  final String impactStatement;
  final bool eligibilityConfirmed;
  final ApplicationStatus status;
  final String reviewerNote;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final DateTime? submittedAt;

  String get statusLabel => switch (status) {
    ApplicationStatus.pending => 'Pending review',
    ApplicationStatus.underReview => 'Under review',
    ApplicationStatus.granted => 'Granted',
    ApplicationStatus.rejected => 'Rejected',
    ApplicationStatus.withdrawn => 'Withdrawn',
  };

  bool get isFinal =>
      status == ApplicationStatus.granted ||
      status == ApplicationStatus.rejected ||
      status == ApplicationStatus.withdrawn;

  OpportunityApplication copyWith({
    ApplicationStatus? status,
    String? reviewerNote,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return OpportunityApplication(
      id: id,
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      providerId: providerId,
      applicantId: applicantId,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      applicantPhone: applicantPhone,
      businessName: businessName,
      businessDescription: businessDescription,
      location: location,
      fundingRequested: fundingRequested,
      howFundsWillBeUsed: howFundsWillBeUsed,
      teamSize: teamSize,
      yearsInOperation: yearsInOperation,
      impactStatement: impactStatement,
      eligibilityConfirmed: eligibilityConfirmed,
      status: status ?? this.status,
      reviewerNote: reviewerNote ?? this.reviewerNote,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      submittedAt: submittedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    opportunityId,
    opportunityTitle,
    providerId,
    applicantId,
    applicantName,
    applicantEmail,
    applicantPhone,
    businessName,
    businessDescription,
    location,
    fundingRequested,
    howFundsWillBeUsed,
    teamSize,
    yearsInOperation,
    impactStatement,
    eligibilityConfirmed,
    status,
    reviewerNote,
    reviewedAt,
    reviewedBy,
    submittedAt,
  ];
}
