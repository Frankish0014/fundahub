import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_profile.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/entities/opportunity_application.dart';

enum OpportunityDetailStatus { initial, loading, loaded, error }

class OpportunityDetailState extends Equatable {
  const OpportunityDetailState({
    this.status = OpportunityDetailStatus.initial,
    this.opportunity,
    this.currentUser,
    this.myApplication,
    this.errorMessage,
  });

  final OpportunityDetailStatus status;
  final Opportunity? opportunity;
  final UserProfile? currentUser;
  final OpportunityApplication? myApplication;
  final String? errorMessage;

  OpportunityDetailState copyWith({
    OpportunityDetailStatus? status,
    Opportunity? opportunity,
    UserProfile? currentUser,
    OpportunityApplication? myApplication,
    String? errorMessage,
    bool clearApplication = false,
  }) {
    return OpportunityDetailState(
      status: status ?? this.status,
      opportunity: opportunity ?? this.opportunity,
      currentUser: currentUser ?? this.currentUser,
      myApplication: clearApplication
          ? myApplication
          : (myApplication ?? this.myApplication),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    opportunity,
    currentUser,
    myApplication,
    errorMessage,
  ];
}
