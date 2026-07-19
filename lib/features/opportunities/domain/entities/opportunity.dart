import 'package:equatable/equatable.dart';

enum OpportunityType { grant, accelerator, scholarship, competition }

class Opportunity extends Equatable {
  const Opportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.type,
    required this.amountLabel,
    required this.tags,
    required this.daysLeft,
    this.isVerified = true,
    this.isSaved = false,
  });

  final String id;
  final String title;
  final String organization;
  final OpportunityType type;
  final String amountLabel;
  final List<String> tags;
  final int daysLeft;
  final bool isVerified;
  final bool isSaved;

  String get typeLabel => switch (type) {
    OpportunityType.grant => 'GRANT',
    OpportunityType.accelerator => 'ACCELERATOR',
    OpportunityType.scholarship => 'SCHOLARSHIP',
    OpportunityType.competition => 'COMPETITION',
  };

  Opportunity copyWith({bool? isSaved}) {
    return Opportunity(
      id: id,
      title: title,
      organization: organization,
      type: type,
      amountLabel: amountLabel,
      tags: tags,
      daysLeft: daysLeft,
      isVerified: isVerified,
      isSaved: isSaved ?? this.isSaved,
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
    isSaved,
  ];
}
