import '../entities/community_post.dart';
import '../entities/post_comment.dart';
import '../repositories/community_repository.dart';

class GetCommunityPosts {
  const GetCommunityPosts(this._repository);

  final CommunityRepository _repository;

  Future<List<CommunityPost>> call({String? sector}) =>
      _repository.getPosts(sector: sector);
}

class GetCommunityPost {
  const GetCommunityPost(this._repository);

  final CommunityRepository _repository;

  Future<CommunityPost?> call(String id) => _repository.getPost(id);
}

class GetPostComments {
  const GetPostComments(this._repository);

  final CommunityRepository _repository;

  Future<List<PostComment>> call(String postId) =>
      _repository.getComments(postId);
}

class AddPostComment {
  const AddPostComment(this._repository);

  final CommunityRepository _repository;

  Future<void> call(
    String postId, {
    required String authorName,
    required String body,
  }) => _repository.addComment(postId, authorName: authorName, body: body);
}
