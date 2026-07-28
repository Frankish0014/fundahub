import 'package:equatable/equatable.dart';

enum AppNotificationType { match, deadline, announcement, moderation }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.type,
    this.createdAt,
    this.targetUserId,
    this.moderationStatus = 'approved',
    this.opportunityId,
  });

  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final AppNotificationType type;
  final DateTime? createdAt;
  final String? targetUserId;
  final String moderationStatus;
  final String? opportunityId;

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    timeAgo,
    type,
    createdAt,
    targetUserId,
    moderationStatus,
    opportunityId,
  ];
}
