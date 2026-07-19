import '../../domain/entities/app_notification.dart';

class NotificationMockDataSource {
  Future<List<AppNotification>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const [
      AppNotification(
        id: 'n1',
        title: 'New Match: Tony Elumelu Foundation',
        body: '98% match based on your tags — Seed Funding & Mentorship.',
        timeAgo: '2 hours ago',
        type: AppNotificationType.match,
      ),
      AppNotification(
        id: 'n2',
        title: 'Deadline Approaching',
        body: 'Google for Startups Accelerator closes in 45 days.',
        timeAgo: '1 day ago',
        type: AppNotificationType.deadline,
      ),
    ];
  }
}
