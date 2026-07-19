import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._dataSource);

  final NotificationMockDataSource _dataSource;

  @override
  Future<List<AppNotification>> getNotifications() => _dataSource.fetchAll();
}
