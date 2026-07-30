import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../opportunities/data/utils/opportunity_search.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../../opportunities/domain/usecases/opportunity_usecases.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required this.getOpportunities, required this.getCurrentUser})
    : super(const SearchState()) {
    on<SearchStarted>(_onStarted);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFiltersChanged>(_onFiltersChanged);
    on<SearchFiltersCleared>(_onFiltersCleared);
    on<SearchRefreshed>(_onRefreshed);
  }

  final GetOpportunities getOpportunities;
  final GetCurrentUser getCurrentUser;

  Future<void> _onStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading, clearError: true));
    try {
      final catalogue = await _loadCatalogue();
      emit(
        state.copyWith(
          status: SearchStatus.success,
          catalogue: catalogue,
          results: _apply(catalogue, state),
        ),
      );
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
      final catalogue = await _loadCatalogue();
      emit(
        state.copyWith(
          status: SearchStatus.success,
          catalogue: catalogue,
          results: _apply(catalogue, state),
          clearError: true,
        ),
      );
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
    final next = state.copyWith(query: event.query);
    // Prefer local filter when catalogue is already loaded.
    if (state.catalogue.isNotEmpty) {
      emit(
        next.copyWith(
          status: SearchStatus.success,
          results: _apply(state.catalogue, next),
        ),
      );
      return;
    }

    emit(next.copyWith(status: SearchStatus.loading, clearError: true));
    try {
      final catalogue = await _loadCatalogue();
      emit(
        next.copyWith(
          status: SearchStatus.success,
          catalogue: catalogue,
          results: _apply(catalogue, next),
        ),
      );
    } catch (e) {
      emit(
        next.copyWith(
          status: SearchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFiltersChanged(
    SearchFiltersChanged event,
    Emitter<SearchState> emit,
  ) async {
    final next = state.copyWith(
      selectedTypes: event.selectedTypes,
      openOnly: event.openOnly,
    );
    if (state.catalogue.isNotEmpty) {
      emit(
        next.copyWith(
          status: SearchStatus.success,
          results: _apply(state.catalogue, next),
        ),
      );
      return;
    }
    emit(next.copyWith(status: SearchStatus.loading, clearError: true));
    try {
      final catalogue = await _loadCatalogue();
      emit(
        next.copyWith(
          status: SearchStatus.success,
          catalogue: catalogue,
          results: _apply(catalogue, next),
        ),
      );
    } catch (e) {
      emit(
        next.copyWith(
          status: SearchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFiltersCleared(
    SearchFiltersCleared event,
    Emitter<SearchState> emit,
  ) async {
    var catalogue = state.catalogue;
    if (catalogue.isEmpty) {
      emit(state.copyWith(status: SearchStatus.loading, clearError: true));
      try {
        catalogue = await _loadCatalogue();
      } catch (e) {
        emit(
          state.copyWith(
            status: SearchStatus.failure,
            errorMessage: e.toString(),
          ),
        );
        return;
      }
    }

    final next = state.copyWith(
      selectedTypes: const {},
      openOnly: false,
      query: '',
      catalogue: catalogue,
    );
    emit(
      next.copyWith(
        status: SearchStatus.success,
        results: _apply(catalogue, next),
        clearError: true,
      ),
    );
  }

  Future<List<Opportunity>> _loadCatalogue() async {
    final user = await getCurrentUser();
    // Always load the full public catalogue; filter locally.
    return getOpportunities(userId: user?.id);
  }

  List<Opportunity> _apply(
    List<Opportunity> catalogue,
    SearchState snapshot,
  ) {
    return OpportunitySearch.filter(
      opportunities: catalogue,
      query: snapshot.query,
      types: snapshot.selectedTypes,
      openOnly: snapshot.openOnly,
    );
  }
}
