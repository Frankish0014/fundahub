import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  const GetNotifications(this._repository);
  final NotificationRepository _repository;
  Future<List<AppNotification>> call({String? userId}) =>
      _repository.getNotifications(userId: userId);
}

class CreateAnnouncement {
  const CreateAnnouncement(this._repository);
  final NotificationRepository _repository;

  Future<void> call({
    required String title,
    required String body,
    required String createdBy,
    required String organization,
    String moderationStatus = 'approved',
  }) => _repository.createAnnouncement(
    title: title,
    body: body,
    createdBy: createdBy,
    organization: organization,
    moderationStatus: moderationStatus,
  );
}

class GetPendingAnnouncements {
  const GetPendingAnnouncements(this._repository);
  final NotificationRepository _repository;

  Future<List<AppNotification>> call() => _repository.getPendingAnnouncements();
}

class ReviewAnnouncement {
  const ReviewAnnouncement(this._repository);
  final NotificationRepository _repository;

  Future<void> call({required String id, required String moderationStatus}) =>
      _repository.reviewAnnouncement(
        id: id,
        moderationStatus: moderationStatus,
      );
}
