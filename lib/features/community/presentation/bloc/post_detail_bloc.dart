import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/community_post.dart';
import '../../domain/entities/post_comment.dart';
import '../../domain/usecases/community_usecases.dart';

part 'post_detail_event.dart';
part 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({
    required this.getCommunityPost,
    required this.getPostComments,
    required this.addPostComment,
  }) : super(const PostDetailState()) {
    on<PostDetailStarted>(_onStarted);
    on<PostDetailCommentSubmitted>(_onCommentSubmitted);
  }

  final GetCommunityPost getCommunityPost;
  final GetPostComments getPostComments;
  final AddPostComment addPostComment;

  Future<void> _onStarted(
    PostDetailStarted event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(
      state.copyWith(status: PostDetailStatus.loading, postId: event.postId),
    );
    try {
      final post = await getCommunityPost(event.postId);
      final comments = await getPostComments(event.postId);
      emit(
        state.copyWith(
          status: PostDetailStatus.success,
          post: post,
          comments: comments,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PostDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCommentSubmitted(
    PostDetailCommentSubmitted event,
    Emitter<PostDetailState> emit,
  ) async {
    final postId = state.postId;
    final body = event.body.trim();
    if (postId == null || body.isEmpty) return;

    emit(state.copyWith(submitting: true));
    try {
      await addPostComment(postId, authorName: event.authorName, body: body);
      final comments = await getPostComments(postId);
      emit(state.copyWith(submitting: false, comments: comments));
    } catch (e) {
      emit(state.copyWith(submitting: false, errorMessage: e.toString()));
    }
  }
}
