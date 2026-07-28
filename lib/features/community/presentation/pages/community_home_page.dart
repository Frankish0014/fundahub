import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';
import '../bloc/community_bloc.dart';

class CommunityHomePage extends StatelessWidget {
  const CommunityHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CommunityBloc(getCommunityPosts: sl())..add(const CommunityStarted()),
      child: const _CommunityView(),
    );
  }
}

class _CommunityView extends StatelessWidget {
  const _CommunityView();

  static const _sectors = ['#AgriTech', '#FinTech', '#EdTech', '#CleanEnergy'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home/profile');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Community',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'TRENDING SECTORS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _sectors.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = index == 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      _sectors[index],
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? AppColors.onPrimary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<CommunityBloc, CommunityState>(
                builder: (context, state) {
                  if (state.status == CommunityStatus.loading ||
                      state.status == CommunityStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == CommunityStatus.failure) {
                    return _CommunityError(
                      message: state.errorMessage,
                      onRetry: () => context.read<CommunityBloc>().add(
                        const CommunityStarted(),
                      ),
                    );
                  }

                  final posts = state.posts;
                  if (posts.isEmpty) {
                    return const Center(child: Text('No posts yet.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: posts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _PostCard(
                        name: post.authorName,
                        meta: post.authorMeta,
                        body: post.body,
                        tags: post.tags,
                        likes: post.likes,
                        comments: post.commentCount,
                        showImage: post.hasImage,
                        isQuote: post.isQuote,
                        onTap: () =>
                            context.push('/community/post', extra: post.id),
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

class _CommunityError extends StatelessWidget {
  const _CommunityError({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load the community feed.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.name,
    required this.meta,
    required this.body,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.onTap,
    this.showImage = false,
    this.isQuote = false,
  });

  final String name;
  final String meta;
  final String body;
  final List<String> tags;
  final int likes;
  final int comments;
  final VoidCallback onTap;
  final bool showImage;
  final bool isQuote;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.avatarBg,
                  child: Text(name.isEmpty ? '?' : name[0]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        meta,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            if (isQuote)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.accent, width: 4),
                  ),
                ),
                child: Text(
                  body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              )
            else
              Text(
                body,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
            if (showImage) ...[
              const SizedBox(height: 12),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: tags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mintSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        t,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.thumb_up_alt_outlined, size: 18),
                const SizedBox(width: 4),
                Text('$likes'),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 18),
                const SizedBox(width: 4),
                Text('$comments'),
                const Spacer(),
                const Icon(Icons.share_outlined, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
