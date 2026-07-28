import 'package:equatable/equatable.dart';

abstract class OpportunityDetailEvent extends Equatable {
  const OpportunityDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadOpportunityDetail extends OpportunityDetailEvent {
  const LoadOpportunityDetail(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class ToggleSaveOpportunity extends OpportunityDetailEvent {
  const ToggleSaveOpportunity(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}