import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/post_comment.dart';
import '../bloc/post_detail_bloc.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, this.postId});

  /// Id of the post to display, passed as router `extra` from the feed.
  final String? postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = PostDetailBloc(
          getCommunityPost: sl(),
          getPostComments: sl(),
          addPostComment: sl(),
        );
        if (postId != null) {
          bloc.add(PostDetailStarted(postId!));
        }
        return bloc;
      },
      child: _PostDetailView(hasId: postId != null),
    );
  }
}

class _PostDetailView extends StatelessWidget {
  const _PostDetailView({required this.hasId});

  final bool hasId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('FundaHub'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.avatarBg,
              child: const Text('A', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PostDetailBloc, PostDetailState>(
        builder: (context, state) {
          if (!hasId) {
            return const Center(child: Text('Post not found.'));
          }
          if (state.status == PostDetailStatus.loading ||
              state.status == PostDetailStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == PostDetailStatus.failure) {
            return const Center(child: Text('Could not load this post.'));
          }
          final post = state.post;
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.avatarBg,
                          child: Text(post.initial),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.authorName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                post.authorMeta,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.verifiedBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.verified,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified Member',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.verified,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      post.body,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, height: 1.25),
                    ),
                    if (post.hasImage) ...[
                      const SizedBox(height: 14),
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.groups_outlined,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.thumb_up_alt_outlined, size: 18),
                        const SizedBox(width: 4),
                        Text('${post.likes}'),
                        const SizedBox(width: 16),
                        const Icon(Icons.chat_bubble_outline, size: 18),
                        const SizedBox(width: 4),
                        Text('${state.comments.length}'),
                        const Spacer(),
                        const Icon(Icons.share_outlined, size: 18),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'COMMENTS (${state.comments.length})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No comments yet. Be the first to reply.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      ..._buildComments(state.comments),
                  ],
                ),
              ),
              _CommentComposer(submitting: state.submitting),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildComments(List<PostComment> comments) {
    final palette = [AppColors.accent, AppColors.primary, Color(0xFF5B8A8A)];
    final widgets = <Widget>[];
    for (var i = 0; i < comments.length; i++) {
      final c = comments[i];
      final card = _CommentCard(
        initials: c.initials,
        color: c.isReply ? AppColors.primary : palette[i % palette.length],
        name: c.authorName,
        time: _timeAgo(c.createdAt),
        body: c.body,
        likes: c.likes,
        isReply: c.isReply,
      );
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 10, left: c.isReply ? 24 : 0),
          child: card,
        ),
      );
    }
    return widgets;
  }

  static String _timeAgo(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _CommentComposer extends StatefulWidget {
  const _CommentComposer({required this.submitting});

  final bool submitting;

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.submitting) return;
    context.read<PostDetailBloc>().add(
      // TODO(armel): use the authenticated user's name once Auth is on Firebase.
      PostDetailCommentSubmitted(authorName: 'You', body: text),
    );
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.avatarBg,
            child: Text('A', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.send,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: widget.submitting ? null : _submit,
            icon: widget.submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.send_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.initials,
    required this.color,
    required this.name,
    required this.time,
    required this.body,
    required this.likes,
    this.isReply = false,
  });

  final String initials;
  final Color color;
  final String name;
  final String time;
  final String body;
  final int likes;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReply ? AppColors.borderStrong : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              initials,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: isReply ? FontStyle.italic : FontStyle.normal,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 14),
                    const SizedBox(width: 4),
                    Text('$likes'),
                    const SizedBox(width: 12),
                    Text(
                      'Reply',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
