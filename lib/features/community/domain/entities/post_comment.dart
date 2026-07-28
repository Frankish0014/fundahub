import 'package:equatable/equatable.dart';

class PostComment extends Equatable {
  const PostComment({
    required this.id,
    required this.authorName,
    required this.body,
    this.likes = 0,
    this.isReply = false,
    this.createdAt,
  });

  final String id;
  final String authorName;
  final String body;
  final int likes;
  final bool isReply;
  final DateTime? createdAt;

  String get initials {
    final parts = authorName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [id, authorName, body, likes, isReply, createdAt];
}
