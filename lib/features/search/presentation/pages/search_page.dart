import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/opportunity_card.dart';
import '../../../../injection/injection.dart';
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
          bloc.add(SearchQueryChanged(seed));
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<SearchBloc>().add(const SearchQueryChanged(''));
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
                      onChanged: (value) {
                        setState(() {});
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
                                onPressed: _clear,
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
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state.status == SearchStatus.loading &&
                      state.results.isEmpty) {
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
                      state.results.isEmpty &&
                      state.query.trim().isNotEmpty) {
                    return SearchNoResultsView(
                      query: state.query,
                      onClearFilters: _clear,
                      onBrowseAll: _clear,
                      onPopularTap: (q) {
                        _controller.text = q;
                        context.read<SearchBloc>().add(SearchQueryChanged(q));
                      },
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: state.results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final opportunity = state.results[index];
                      return OpportunityCard(
                        opportunity: opportunity,
                        onTap: () =>
                            context.push('/opportunities/${opportunity.id}'),
                      );
                    },
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
