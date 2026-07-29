import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../domain/usecases/application_usecases.dart';
import '../../domain/usecases/opportunity_usecases.dart';
import 'opportunity_detail_event.dart';
import 'opportunity_detail_state.dart';

class OpportunityDetailBloc
    extends Bloc<OpportunityDetailEvent, OpportunityDetailState> {
  OpportunityDetailBloc({
    required GetOpportunityById getOpportunityById,
    required ToggleSavedOpportunity toggleSavedOpportunity,
    required GetCurrentUser getCurrentUser,
    required GetMyApplicationForOpportunity getMyApplication,
  }) : _getOpportunityById = getOpportunityById,
       _toggleSavedOpportunity = toggleSavedOpportunity,
       _getCurrentUser = getCurrentUser,
       _getMyApplication = getMyApplication,
       super(const OpportunityDetailState()) {
    on<LoadOpportunityDetail>(_onLoad);
    on<ToggleSaveOpportunity>(_onToggleSave);
  }

  final GetOpportunityById _getOpportunityById;
  final ToggleSavedOpportunity _toggleSavedOpportunity;
  final GetCurrentUser _getCurrentUser;
  final GetMyApplicationForOpportunity _getMyApplication;

  Future<void> _onLoad(
    LoadOpportunityDetail event,
    Emitter<OpportunityDetailState> emit,
  ) async {
    emit(state.copyWith(status: OpportunityDetailStatus.loading));
    try {
      final user = await _getCurrentUser();
      final isStaff =
          user != null && (user.isPlatformAdmin || user.isOpportunityProvider);
      final opportunity = await _getOpportunityById(
        event.id,
        userId: user?.id,
        allowNonPublic: isStaff,
      );
      // Providers may only open their own non-public listings.
      if (opportunity != null &&
          !opportunity.isPublic &&
          user != null &&
          user.isOpportunityProvider &&
          !user.isPlatformAdmin &&
          opportunity.createdBy != user.id) {
        emit(
          state.copyWith(
            status: OpportunityDetailStatus.loaded,
            opportunity: null,
            currentUser: user,
            clearApplication: true,
          ),
        );
        return;
      }
      final application =
          user == null || opportunity == null || !opportunity.isPublic
          ? null
          : await _getMyApplication(
              opportunityId: event.id,
              applicantId: user.id,
            );
      emit(
        state.copyWith(
          status: OpportunityDetailStatus.loaded,
          opportunity: opportunity,
          currentUser: user,
          myApplication: application,
          clearApplication: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OpportunityDetailStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleSave(
    ToggleSaveOpportunity event,
    Emitter<OpportunityDetailState> emit,
  ) async {
    final user = await _getCurrentUser();
    if (user == null) return;
    await _toggleSavedOpportunity(event.id, userId: user.id);
    add(LoadOpportunityDetail(event.id));
  }
}
