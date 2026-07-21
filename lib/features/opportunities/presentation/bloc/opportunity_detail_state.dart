import 'package:equatable/equatable.dart';

import '../../domain/entities/opportunity.dart';

enum OpportunityDetailStatus { initial, loading, loaded, error }

class OpportunityDetailState extends Equatable {
  const OpportunityDetailState({
    this.status = OpportunityDetailStatus.initial,
    this.opportunity,
    this.errorMessage,
  });

  final OpportunityDetailStatus status;
  final Opportunity? opportunity;
  final String? errorMessage;

  OpportunityDetailState copyWith({
    OpportunityDetailStatus? status,
    Opportunity? opportunity,
    String? errorMessage,
  }) {
    return OpportunityDetailState(
      status: status ?? this.status,
      opportunity: opportunity ?? this.opportunity,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, opportunity, errorMessage];
}
