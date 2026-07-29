import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._dataSource);

  final NotificationRemoteDataSource _dataSource;

  @override
  Future<List<AppNotification>> getNotifications({String? userId}) =>
      _dataSource.fetchForUser(userId);

  @override
  Future<List<AppNotification>> getPendingAnnouncements() =>
      _dataSource.fetchPendingAnnouncements();

  @override
  Future<void> reviewAnnouncement({
    required String id,
    required String moderationStatus,
  }) => _dataSource.reviewAnnouncement(
    id: id,
    moderationStatus: moderationStatus,
  );

  @override
  Future<void> createAnnouncement({
    required String title,
    required String body,
    required String createdBy,
    required String organization,
    String moderationStatus = 'approved',
  }) => _dataSource.createAnnouncement(
    title: title,
    body: body,
    createdBy: createdBy,
    organization: organization,
    moderationStatus: moderationStatus,
  );

  @override
  Future<void> notifyUser({
    required String targetUserId,
    required String title,
    required String body,
    required String organization,
  }) => _dataSource.createAnnouncement(
    title: title,
    body: body,
    createdBy: 'system',
    organization: organization,
    targetUserId: targetUserId,
    moderationStatus: 'approved',
  );
}
