part of 'post_detail_bloc.dart';

enum PostDetailStatus { initial, loading, success, failure }

class PostDetailState extends Equatable {
  const PostDetailState({
    this.status = PostDetailStatus.initial,
    this.postId,
    this.post,
    this.comments = const [],
    this.submitting = false,
    this.errorMessage,
  });

  final PostDetailStatus status;
  final String? postId;
  final CommunityPost? post;
  final List<PostComment> comments;
  final bool submitting;
  final String? errorMessage;

  PostDetailState copyWith({
    PostDetailStatus? status,
    String? postId,
    CommunityPost? post,
    List<PostComment>? comments,
    bool? submitting,
    String? errorMessage,
  }) {
    return PostDetailState(
      status: status ?? this.status,
      postId: postId ?? this.postId,
      post: post ?? this.post,
      comments: comments ?? this.comments,
      submitting: submitting ?? this.submitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    postId,
    post,
    comments,
    submitting,
    errorMessage,
  ];
}
