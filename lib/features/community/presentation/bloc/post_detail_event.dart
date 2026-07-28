part of 'post_detail_bloc.dart';

sealed class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

class PostDetailStarted extends PostDetailEvent {
  const PostDetailStarted(this.postId);

  final String postId;

  @override
  List<Object?> get props => [postId];
}

class PostDetailCommentSubmitted extends PostDetailEvent {
  const PostDetailCommentSubmitted({
    required this.authorName,
    required this.body,
  });

  final String authorName;
  final String body;

  @override
  List<Object?> get props => [authorName, body];
}
