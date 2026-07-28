import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/opportunity_usecases.dart';
import 'opportunity_detail_event.dart';
import 'opportunity_detail_state.dart';

class OpportunityDetailBloc
    extends Bloc<OpportunityDetailEvent, OpportunityDetailState> {
  OpportunityDetailBloc({
    required this._getOpportunityById,
    required this._toggleSavedOpportunity,
  }) :
        super(const OpportunityDetailState()) {
    on<LoadOpportunityDetail>(_onLoad);
    on<ToggleSaveOpportunity>(_onToggleSave);
  }

  final GetOpportunityById _getOpportunityById;
  final ToggleSavedOpportunity _toggleSavedOpportunity;

  Future<void> _onLoad(
    LoadOpportunityDetail event,
    Emitter<OpportunityDetailState> emit,
  ) async {
    emit(state.copyWith(status: OpportunityDetailStatus.loading));
    try {
      final opportunity = await _getOpportunityById(event.id);
      emit(state.copyWith(
        status: OpportunityDetailStatus.loaded,
        opportunity: opportunity,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OpportunityDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleSave(
    ToggleSaveOpportunity event,
    Emitter<OpportunityDetailState> emit,
  ) async {
    await _toggleSavedOpportunity(event.id);
    add(LoadOpportunityDetail(event.id));
  }
}