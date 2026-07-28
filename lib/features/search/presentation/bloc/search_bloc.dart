import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../../opportunities/domain/usecases/opportunity_usecases.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required this.getOpportunities,
    required this.getCurrentUser,
  }) : super(const SearchState()) {
    on<SearchStarted>(_onStarted);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchRefreshed>(_onRefreshed);
  }

  final GetOpportunities getOpportunities;
  final GetCurrentUser getCurrentUser;

  Future<void> _onStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final user = await getCurrentUser();
      final results = await getOpportunities(userId: user?.id);
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

  Future<void> _onRefreshed(
    SearchRefreshed event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final user = await getCurrentUser();
      final results = await getOpportunities(
        query: state.query,
        userId: user?.id,
      );
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
      final user = await getCurrentUser();
      final results = await getOpportunities(
        query: event.query,
        userId: user?.id,
      );
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
