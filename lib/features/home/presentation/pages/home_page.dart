import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/opportunity_card.dart';
import '../../../../injection/injection.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HomeBloc(getCurrentUser: sl(), getRecommended: sl())
            ..add(const HomeStarted()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final name = state.user?.firstName ?? 'Andrew';

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
                      decoration: const BoxDecoration(color: AppColors.primary),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.onPrimary.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                ),
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
                            hintText: 'Search grants, accelerators...',
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
                        'Recommended for you',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/home/search'),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    final carouselH = OpportunityCard.carouselHeight(context);
                    final cardW = (MediaQuery.sizeOf(context).width * 0.78)
                        .clamp(260.0, 320.0);
                    return SizedBox(
                      height: carouselH,
                      child: state.status == HomeStatus.loading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: state.recommended.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: cardW,
                                  height: carouselH,
                                  child: OpportunityCard(
                                    opportunity: state.recommended[index],
                                    dense: true,
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
                    'Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
                            (category) => Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
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
  }
}
