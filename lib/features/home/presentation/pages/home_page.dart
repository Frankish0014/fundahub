import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/session/current_user_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/opportunity_card.dart';
import '../../../../injection/injection.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        getCurrentUser: sl(),
        getRecommended: sl(),
        currentUser: sl(),
      )..add(const HomeStarted()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl<CurrentUserController>(),
      builder: (context, _) {
        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final s = AppStrings.of(context);
            // Prefer live session profile so edits show immediately.
            final liveUser = sl<CurrentUserController>().user ?? state.user;
            final name = liveUser?.fullName.trim();
            final hasName = name != null && name.isNotEmpty;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            top: MediaQuery.paddingOf(context).top + 20,
                            left: 20,
                            right: 20,
                            bottom: 48,
                          ),
                          decoration: BoxDecoration(color: AppColors.primary),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.welcomeBackName(name ?? ''),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.onPrimary
                                                .withValues(alpha: 0.85),
                                          ),
                                    ),
                                    if (hasName)
                                      Text(
                                        name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              color: AppColors.onPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => context.go('/home/alerts'),
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: -24,
                          child: Material(
                            elevation: 2,
                            shadowColor: Colors.black26,
                            borderRadius: BorderRadius.circular(14),
                            child: TextField(
                              readOnly: true,
                              onTap: () => context.go('/home/search'),
                              decoration: InputDecoration(
                                hintText: s.searchHint,
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            s.recommendedForYou,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.go('/home/search'),
                            child: Text(s.seeAll),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        final carouselH = OpportunityCard.carouselHeight(
                          context,
                        );
                        final cardW = (MediaQuery.sizeOf(context).width * 0.78)
                            .clamp(260.0, 320.0);

                        if (state.status == HomeStatus.loading ||
                            state.status == HomeStatus.initial) {
                          return SizedBox(
                            height: carouselH,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (state.status == HomeStatus.failure) {
                          return SizedBox(
                            height: carouselH,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Could not load opportunities.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => context
                                          .read<HomeBloc>()
                                          .add(const HomeStarted()),
                                      child: Text(s.retry),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        if (state.recommended.isEmpty) {
                          return SizedBox(
                            height: carouselH,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'No opportunities yet. Pull to refresh or open Search.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: carouselH,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: state.recommended.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final opportunity = state.recommended[index];
                              return SizedBox(
                                width: cardW,
                                height: carouselH,
                                child: OpportunityCard(
                                  opportunity: opportunity,
                                  dense: true,
                                  onTap: () => context.push(
                                    '/opportunities/${opportunity.id}',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        s.categories,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final crossCount = width < 340 ? 1 : 2;
                        final aspect = width < 340 ? 4.5 : 2.6;
                        return SliverGrid.count(
                          crossAxisCount: crossCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: aspect,
                          children: AppConstants.categories
                              .map(
                                (category) => Material(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => context.go(
                                      '/home/search',
                                      extra: category,
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Text(
                                        s.categoryLabel(category),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
