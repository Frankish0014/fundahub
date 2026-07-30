part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchStarted extends SearchEvent {
  const SearchStarted();
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchFiltersChanged extends SearchEvent {
  const SearchFiltersChanged({
    this.selectedTypes = const {},
    this.openOnly = false,
  });

  final Set<OpportunityType> selectedTypes;
  final bool openOnly;

  @override
  List<Object?> get props => [selectedTypes, openOnly];
}

class SearchFiltersCleared extends SearchEvent {
  const SearchFiltersCleared();
}

class SearchRefreshed extends SearchEvent {
  const SearchRefreshed();
}
