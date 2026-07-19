import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../opportunities/domain/entities/opportunity.dart';
import '../../../opportunities/domain/usecases/opportunity_usecases.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required this.getOpportunities}) : super(const SearchState()) {
    on<SearchStarted>(_onStarted);
    on<SearchQueryChanged>(_onQueryChanged);
  }

  final GetOpportunities getOpportunities;

  Future<void> _onStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final results = await getOpportunities();
      emit(state.copyWith(status: SearchStatus.success, results: results));
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(query: event.query, status: SearchStatus.loading));
    try {
      final results = await getOpportunities(query: event.query);
      emit(state.copyWith(status: SearchStatus.success, results: results));
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
