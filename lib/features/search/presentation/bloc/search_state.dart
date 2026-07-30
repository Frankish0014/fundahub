part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.catalogue = const [],
    this.results = const [],
    this.selectedTypes = const {},
    this.openOnly = false,
    this.errorMessage,
  });

  final SearchStatus status;
  final String query;

  /// Full public catalogue (cached for fast local filtering).
  final List<Opportunity> catalogue;
  final List<Opportunity> results;
  final Set<OpportunityType> selectedTypes;
  final bool openOnly;
  final String? errorMessage;

  bool get hasActiveFilters => selectedTypes.isNotEmpty || openOnly;

  int get activeFilterCount =>
      selectedTypes.length + (openOnly ? 1 : 0);

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Opportunity>? catalogue,
    List<Opportunity>? results,
    Set<OpportunityType>? selectedTypes,
    bool? openOnly,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      catalogue: catalogue ?? this.catalogue,
      results: results ?? this.results,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      openOnly: openOnly ?? this.openOnly,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    catalogue,
    results,
    selectedTypes,
    openOnly,
    errorMessage,
  ];
}
