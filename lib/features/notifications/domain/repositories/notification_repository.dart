import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications({String? userId});
  Future<List<AppNotification>> getPendingAnnouncements();
  Future<void> reviewAnnouncement({
    required String id,
    required String moderationStatus,
  });
  Future<void> createAnnouncement({
    required String title,
    required String body,
    required String createdBy,
    required String organization,
    String moderationStatus = 'approved',
  });
  Future<void> notifyUser({
    required String targetUserId,
    required String title,
    required String body,
    required String organization,
  });
}
