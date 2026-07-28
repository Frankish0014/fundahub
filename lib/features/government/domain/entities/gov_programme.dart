import 'package:equatable/equatable.dart';

/// A single step in a programme's application process.
class GovStep extends Equatable {
  const GovStep({
    required this.number,
    required this.title,
    required this.body,
    this.active = false,
  });

  final int number;
  final String title;
  final String body;
  final bool active;

  @override
  List<Object?> get props => [number, title, body, active];
}

class GovProgramme extends Equatable {
  const GovProgramme({
    required this.id,
    required this.title,
    required this.issuer,
    this.category = 'All Programs',
    this.amountCaption = 'GRANT AMOUNT',
    this.amount = '',
    this.deadlineLabel = '',
    this.closed = false,
    this.verified = true,
    this.tags = const [],
    // Detail-only fields (optional):
    this.deadlineDate = '',
    this.organizedBy = '',
    this.eligibility = const [],
    this.steps = const [],
    this.links = const [],
    this.statusLabel = '',
    this.daysLeftLabel = '',
    this.quote = '',
  });

  final String id;
  final String title;
  final String issuer;

  /// Filter bucket, e.g. "Agriculture", "Tech Startups".
  final String category;

  /// Caption above the amount on the list card, e.g. "FUNDING CAP".
  final String amountCaption;
  final String amount;
  final String deadlineLabel;
  final bool closed;
  final bool verified;
  final List<String> tags;

  final String deadlineDate;
  final String organizedBy;
  final List<String> eligibility;
  final List<GovStep> steps;
  final List<String> links;
  final String statusLabel;
  final String daysLeftLabel;
  final String quote;

  @override
  List<Object?> get props => [
    id,
    title,
    issuer,
    category,
    amountCaption,
    amount,
    deadlineLabel,
    closed,
    verified,
    tags,
    deadlineDate,
    organizedBy,
    eligibility,
    steps,
    links,
    statusLabel,
    daysLeftLabel,
    quote,
  ];
}
