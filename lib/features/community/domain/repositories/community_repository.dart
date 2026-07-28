import '../entities/community_post.dart';
import '../entities/post_comment.dart';

abstract class CommunityRepository {
  /// Returns community posts, newest first. [sector] optionally filters by a
  /// trending-sector tag (e.g. "#AgriTech").
  Future<List<CommunityPost>> getPosts({String? sector});

  Future<CommunityPost?> getPost(String id);

  /// Returns comments for a post, oldest first.
  Future<List<PostComment>> getComments(String postId);

  Future<void> addComment(
    String postId, {
    required String authorName,
    required String body,
  });

  Future<String> createPost({
    required String authorName,
    required String authorMeta,
    required String body,
    List<String> tags = const [],
  });
}
