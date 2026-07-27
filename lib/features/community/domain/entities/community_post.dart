import 'package:equatable/equatable.dart';

class CommunityPost extends Equatable {
  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorMeta,
    required this.body,
    this.tags = const [],
    this.likes = 0,
    this.commentCount = 0,
    this.hasImage = false,
    this.isQuote = false,
    this.createdAt,
  });

  final String id;
  final String authorName;

  /// Secondary line under the author, e.g. "2h ago • Founder, GreenRoots".
  final String authorMeta;
  final String body;
  final List<String> tags;
  final int likes;
  final int commentCount;
  final bool hasImage;
  final bool isQuote;
  final DateTime? createdAt;

  String get initial =>
      authorName.isEmpty ? '?' : authorName.trim()[0].toUpperCase();

  @override
  List<Object?> get props => [
    id,
    authorName,
    authorMeta,
    body,
    tags,
    likes,
    commentCount,
    hasImage,
    isQuote,
    createdAt,
  ];
}
