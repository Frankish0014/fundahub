import 'package:equatable/equatable.dart';

enum OpportunityType { grant, accelerator, scholarship, competition }

/// Admin gate: only [approved] opportunities appear for entrepreneurs.
enum ModerationStatus { pending, approved, rejected }

class Opportunity extends Equatable {
  const Opportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.type,
    required this.amountLabel,
    required this.tags,
    required this.daysLeft,
    this.isVerified = false,
    this.moderationStatus = ModerationStatus.pending,
    this.moderationNote = '',
    this.reviewedBy,
    this.reviewedAt,
    this.isSaved = false,
    this.createdBy,
    this.createdAt,
    this.description = '',
    this.eligibilityCriteria = '',
    this.requiredDocuments = const [],
    this.location = '',
    this.contactEmail = '',
    this.applicationInstructions = '',
    this.targetBeneficiaries = '',
  });

  final String id;
  final String title;
  final String organization;
  final OpportunityType type;
  final String amountLabel;
  final List<String> tags;
  final int daysLeft;

  /// True only after platform admin approval.
  final bool isVerified;
  final ModerationStatus moderationStatus;
  final String moderationNote;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  final bool isSaved;
  final String? createdBy;
  final DateTime? createdAt;
  final String description;
  final String eligibilityCriteria;
  final List<String> requiredDocuments;
  final String location;
  final String contactEmail;
  final String applicationInstructions;
  final String targetBeneficiaries;

  String get typeLabel => switch (type) {
    OpportunityType.grant => 'GRANT',
    OpportunityType.accelerator => 'ACCELERATOR',
    OpportunityType.scholarship => 'SCHOLARSHIP',
    OpportunityType.competition => 'COMPETITION',
  };

  String get moderationLabel => switch (moderationStatus) {
    ModerationStatus.pending => 'Pending',
    ModerationStatus.approved => 'Approved',
    ModerationStatus.rejected => 'Rejected',
  };

  bool get isOpen => daysLeft > 0;
  bool get isPublic =>
      moderationStatus == ModerationStatus.approved && isVerified;

  Opportunity copyWith({
    bool? isSaved,
    bool? isVerified,
    ModerationStatus? moderationStatus,
    String? moderationNote,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return Opportunity(
      id: id,
      title: title,
      organization: organization,
      type: type,
      amountLabel: amountLabel,
      tags: tags,
      daysLeft: daysLeft,
      isVerified: isVerified ?? this.isVerified,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationNote: moderationNote ?? this.moderationNote,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      isSaved: isSaved ?? this.isSaved,
      createdBy: createdBy,
      createdAt: createdAt,
      description: description,
      eligibilityCriteria: eligibilityCriteria,
      requiredDocuments: requiredDocuments,
      location: location,
      contactEmail: contactEmail,
      applicationInstructions: applicationInstructions,
      targetBeneficiaries: targetBeneficiaries,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    organization,
    type,
    amountLabel,
    tags,
    daysLeft,
    isVerified,
    moderationStatus,
    moderationNote,
    reviewedBy,
    reviewedAt,
    isSaved,
    createdBy,
    createdAt,
    description,
    eligibilityCriteria,
    requiredDocuments,
    location,
    contactEmail,
    applicationInstructions,
    targetBeneficiaries,
  ];
}
