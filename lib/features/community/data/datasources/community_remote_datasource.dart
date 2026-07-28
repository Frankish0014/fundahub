import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/community_post.dart';
import '../../domain/entities/post_comment.dart';

abstract class CommunityRemoteDataSource {
  Future<List<CommunityPost>> fetchPosts({String? sector});
  Future<CommunityPost?> fetchPost(String id);
  Future<List<PostComment>> fetchComments(String postId);
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

/// Firestore-backed community datasource.
///
/// Layout:
///   community_posts/{postId}
///   community_posts/{postId}/comments/{commentId}
class CommunityFirestoreDataSource implements CommunityRemoteDataSource {
  CommunityFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  bool _seedChecked = false;

  static const _postsCollection = 'community_posts';
  static const _commentsCollection = 'comments';

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection(_postsCollection);

  @override
  Future<List<CommunityPost>> fetchPosts({String? sector}) async {
    await _ensureSeeded();

    if (sector != null && sector.trim().isNotEmpty) {
      // Avoid a composite index requirement: filter server-side, sort locally.
      final snap = await _posts.where('tags', arrayContains: sector).get();
      final items = snap.docs.map(_postFromDoc).toList()
        ..sort((a, b) => _compareByCreatedDesc(a, b));
      return items;
    }

    final snap = await _posts.orderBy('createdAt', descending: true).get();
    return snap.docs.map(_postFromDoc).toList();
  }

  @override
  Future<CommunityPost?> fetchPost(String id) async {
    final doc = await _posts.doc(id).get();
    if (!doc.exists) return null;
    return _postFromDoc(doc);
  }

  @override
  Future<List<PostComment>> fetchComments(String postId) async {
    final snap = await _posts
        .doc(postId)
        .collection(_commentsCollection)
        .orderBy('createdAt')
        .get();
    return snap.docs.map(_commentFromDoc).toList();
  }

  @override
  Future<void> addComment(
    String postId, {
    required String authorName,
    required String body,
  }) async {
    final postRef = _posts.doc(postId);
    await postRef.collection(_commentsCollection).add({
      'authorName': authorName,
      'body': body,
      'likes': 0,
      'isReply': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await postRef.update({'commentCount': FieldValue.increment(1)});
  }

  @override
  Future<String> createPost({
    required String authorName,
    required String authorMeta,
    required String body,
    List<String> tags = const [],
  }) async {
    final ref = await _posts.add({
      'authorName': authorName,
      'authorMeta': authorMeta,
      'body': body,
      'tags': tags,
      'likes': 0,
      'commentCount': 0,
      'hasImage': false,
      'isQuote': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // --- mapping helpers -------------------------------------------------------

  CommunityPost _postFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return CommunityPost(
      id: doc.id,
      authorName: d['authorName'] as String? ?? '',
      authorMeta: d['authorMeta'] as String? ?? '',
      body: d['body'] as String? ?? '',
      tags: (d['tags'] as List?)?.cast<String>() ?? const [],
      likes: (d['likes'] as num?)?.toInt() ?? 0,
      commentCount: (d['commentCount'] as num?)?.toInt() ?? 0,
      hasImage: d['hasImage'] as bool? ?? false,
      isQuote: d['isQuote'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  PostComment _commentFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return PostComment(
      id: doc.id,
      authorName: d['authorName'] as String? ?? '',
      body: d['body'] as String? ?? '',
      likes: (d['likes'] as num?)?.toInt() ?? 0,
      isReply: d['isReply'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  int _compareByCreatedDesc(CommunityPost a, CommunityPost b) {
    final at = a.createdAt;
    final bt = b.createdAt;
    if (at == null && bt == null) return 0;
    if (at == null) return 1;
    if (bt == null) return -1;
    return bt.compareTo(at);
  }

  // --- seeding ---------------------------------------------------------------

  /// Seeds the feed with the original Figma sample content the first time the
  /// app runs against an empty collection. Idempotent: does nothing once the
  /// collection has documents.
  Future<void> _ensureSeeded() async {
    if (_seedChecked) return;
    final existing = await _posts.limit(1).get();
    _seedChecked = true;
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final batch = _firestore.batch();

    final post1 = _posts.doc();
    batch.set(post1, {
      'authorName': 'Amara Okafor',
      'authorMeta': '2h ago • Founder, GreenRoots',
      'body':
          'Just closed our first round of seed funding! Grateful for the mentors who pushed us to tighten the unit economics. 🌱',
      'tags': ['#AgriTech', '#FundingSuccess'],
      'likes': 124,
      'commentCount': 3,
      'hasImage': false,
      'isQuote': false,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
    });

    final post2 = _posts.doc();
    batch.set(post2, {
      'authorName': 'Kofi Mensah',
      'authorMeta': '5h ago • Logistics Strategist',
      'body':
          'Anyone solving last-mile delivery challenges in Accra? Looking for IoT partners.',
      'tags': ['#Logistics', '#IoT'],
      'likes': 89,
      'commentCount': 0,
      'hasImage': true,
      'isQuote': false,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 5))),
    });

    final post3 = _posts.doc();
    batch.set(post3, {
      'authorName': 'Dr. Samuel Adeyemi',
      'authorMeta': '8h ago • Angel Investor',
      'body':
          'Your business model is only as strong as the problem you refuse to ignore.',
      'tags': ['#Entrepreneurship', '#Advice'],
      'likes': 210,
      'commentCount': 0,
      'hasImage': false,
      'isQuote': true,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 8))),
    });

    // Seed comments on the first post (matches the post-detail sample).
    final comments = post1.collection(_commentsCollection);
    batch.set(comments.doc(), {
      'authorName': 'Kemi Okoro',
      'body':
          'Focus on retention cohorts early. Investors ask for that before burn rate.',
      'likes': 12,
      'isReply': false,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
    });
    batch.set(comments.doc(), {
      'authorName': 'Amara Okafor',
      'body': 'Exactly — we rebuilt our dashboard around that.',
      'likes': 4,
      'isReply': true,
      'createdAt': Timestamp.fromDate(
        now.subtract(const Duration(minutes: 45)),
      ),
    });
    batch.set(comments.doc(), {
      'authorName': 'Michael Njoroge',
      'body': 'Happy to share our seed deck checklist if useful.',
      'likes': 8,
      'isReply': false,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
    });

    await batch.commit();
  }
}
