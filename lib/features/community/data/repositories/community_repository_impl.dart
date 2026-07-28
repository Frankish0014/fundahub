import '../../domain/entities/community_post.dart';
import '../../domain/entities/post_comment.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl(this._dataSource);

  final CommunityRemoteDataSource _dataSource;

  @override
  Future<List<CommunityPost>> getPosts({String? sector}) =>
      _dataSource.fetchPosts(sector: sector);

  @override
  Future<CommunityPost?> getPost(String id) => _dataSource.fetchPost(id);

  @override
  Future<List<PostComment>> getComments(String postId) =>
      _dataSource.fetchComments(postId);

  @override
  Future<void> addComment(
    String postId, {
    required String authorName,
    required String body,
  }) => _dataSource.addComment(postId, authorName: authorName, body: body);

  @override
  Future<String> createPost({
    required String authorName,
    required String authorMeta,
    required String body,
    List<String> tags = const [],
  }) =>
      _dataSource.createPost(
        authorName: authorName,
        authorMeta: authorMeta,
        body: body,
        tags: tags,
      );
}
