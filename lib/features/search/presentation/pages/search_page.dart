import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/opportunity_card.dart';
import '../../../../injection/injection.dart';
import '../../../opportunities/data/utils/opportunity_search.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../bloc/search_bloc.dart';
import 'search_no_results_view.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = SearchBloc(getOpportunities: sl(), getCurrentUser: sl());
        final seed = initialQuery?.trim();
        if (seed != null && seed.isNotEmpty) {
          // Seed category/type from home tiles into filters when possible.
          final type = OpportunitySearch.typeForCategory(seed);
          if (type != null) {
            bloc.add(SearchFiltersChanged(selectedTypes: {type}));
          } else {
            bloc.add(SearchQueryChanged(seed));
          }
        } else {
          bloc.add(const SearchStarted());
        }
        return bloc;
      },
      child: _SearchView(initialQuery: initialQuery),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView({this.initialQuery});

  final String? initialQuery;

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialQuery?.trim() ?? '';
    final isCategory = OpportunitySearch.typeForCategory(seed) != null;
    _controller = TextEditingController(text: isCategory ? '' : seed);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryTyped(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      context.read<SearchBloc>().add(SearchQueryChanged(value));
    });
  }

  void _clearQuery() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {});
    context.read<SearchBloc>().add(const SearchQueryChanged(''));
  }

  void _clearAll() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {});
    context.read<SearchBloc>().add(const SearchFiltersCleared());
  }

  Future<void> _openFilters(SearchState state) async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SearchFilterSheet(
        selectedTypes: state.selectedTypes,
        openOnly: state.openOnly,
      ),
    );
    if (!mounted || result == null) return;
    context.read<SearchBloc>().add(
      SearchFiltersChanged(
        selectedTypes: result.types,
        openOnly: result.openOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onChanged: _onQueryTyped,
                      onSubmitted: (value) {
                        _debounce?.cancel();
                        context.read<SearchBloc>().add(
                          SearchQueryChanged(value),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: s.searchOpportunities,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _clearQuery,
                              ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BlocBuilder<SearchBloc, SearchState>(
                    buildWhen: (p, n) =>
                        p.hasActiveFilters != n.hasActiveFilters ||
                        p.activeFilterCount != n.activeFilterCount,
                    builder: (context, state) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: state.hasActiveFilters
                                  ? AppColors.mintSoft
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: state.hasActiveFilters
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: IconButton(
                              tooltip: 'Filters',
                              onPressed: () => _openFilters(state),
                              icon: Icon(
                                Icons.tune_rounded,
                                color: state.hasActiveFilters
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (state.activeFilterCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  '${state.activeFilterCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            BlocBuilder<SearchBloc, SearchState>(
              buildWhen: (p, n) =>
                  p.selectedTypes != n.selectedTypes ||
                  p.openOnly != n.openOnly ||
                  p.results.length != n.results.length ||
                  p.status != n.status,
              builder: (context, state) {
                if (state.status != SearchStatus.success &&
                    state.results.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.hasActiveFilters) ...[
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (final type in state.selectedTypes)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InputChip(
                                    label: Text(
                                      OpportunitySearch.categoryLabelForType(
                                        type,
                                      ),
                                    ),
                                    onDeleted: () {
                                      final next = {...state.selectedTypes}
                                        ..remove(type);
                                      context.read<SearchBloc>().add(
                                        SearchFiltersChanged(
                                          selectedTypes: next,
                                          openOnly: state.openOnly,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (state.openOnly)
                                InputChip(
                                  label: const Text('Open only'),
                                  onDeleted: () {
                                    context.read<SearchBloc>().add(
                                      SearchFiltersChanged(
                                        selectedTypes: state.selectedTypes,
                                        openOnly: false,
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        state.results.isEmpty
                            ? 'No matches'
                            : '${state.results.length} opportunit'
                                  '${state.results.length == 1 ? 'y' : 'ies'}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state.status == SearchStatus.loading &&
                      state.results.isEmpty &&
                      state.catalogue.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == SearchStatus.failure) {
                    return Center(
                      child: TextButton(
                        onPressed: () => context.read<SearchBloc>().add(
                          const SearchStarted(),
                        ),
                        child: Text(AppStrings.of(context).retry),
                      ),
                    );
                  }
                  if (state.status == SearchStatus.success &&
                      state.catalogue.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No verified opportunities yet. Check back after providers publish listings.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }
                  if (state.status == SearchStatus.success &&
                      state.results.isEmpty &&
                      (state.query.trim().isNotEmpty ||
                          state.hasActiveFilters)) {
                    return SearchNoResultsView(
                      query: state.query,
                      onClearFilters: _clearAll,
                      onBrowseAll: _clearAll,
                      onPopularTap: (q) {
                        _controller.text = q;
                        setState(() {});
                        context.read<SearchBloc>().add(SearchQueryChanged(q));
                      },
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<SearchBloc>().add(const SearchRefreshed());
                      await context.read<SearchBloc>().stream.firstWhere(
                        (s) => s.status != SearchStatus.loading,
                      );
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: state.results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final opportunity = state.results[index];
                        return OpportunityCard(
                          opportunity: opportunity,
                          onTap: () => context.push(
                            '/opportunities/${opportunity.id}',
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterResult {
  const _FilterResult({required this.types, required this.openOnly});
  final Set<OpportunityType> types;
  final bool openOnly;
}

class _SearchFilterSheet extends StatefulWidget {
  const _SearchFilterSheet({
    required this.selectedTypes,
    required this.openOnly,
  });

  final Set<OpportunityType> selectedTypes;
  final bool openOnly;

  @override
  State<_SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<_SearchFilterSheet> {
  late Set<OpportunityType> _types;
  late bool _openOnly;

  @override
  void initState() {
    super.initState();
    _types = {...widget.selectedTypes};
    _openOnly = widget.openOnly;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Filter opportunities',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Narrow verified listings by type and deadline.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Text(
            'Type',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in AppConstants.categories)
                FilterChip(
                  label: Text(category),
                  selected: _types.contains(
                    OpportunitySearch.typeForCategoryLabel(category),
                  ),
                  onSelected: (selected) {
                    final type = OpportunitySearch.typeForCategoryLabel(
                      category,
                    );
                    if (type == null) return;
                    setState(() {
                      if (selected) {
                        _types = {..._types, type};
                      } else {
                        _types = {..._types}..remove(type);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Open applications only'),
            subtitle: const Text('Hide closed opportunities'),
            value: _openOnly,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _openOnly = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _types = {};
                      _openOnly = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _FilterResult(types: _types, openOnly: _openOnly),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size.fromHeight(50),
                    elevation: 0,
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
