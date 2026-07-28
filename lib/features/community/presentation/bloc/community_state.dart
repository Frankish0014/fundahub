part of 'community_bloc.dart';

enum CommunityStatus { initial, loading, success, failure }

class CommunityState extends Equatable {
  const CommunityState({
    this.status = CommunityStatus.initial,
    this.posts = const [],
    this.errorMessage,
  });

  final CommunityStatus status;
  final List<CommunityPost> posts;
  final String? errorMessage;

  CommunityState copyWith({
    CommunityStatus? status,
    List<CommunityPost>? posts,
    String? errorMessage,
  }) {
    return CommunityState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, posts, errorMessage];
}
