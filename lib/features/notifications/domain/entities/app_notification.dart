import 'package:equatable/equatable.dart';

enum AppNotificationType { match, deadline }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.type,
  });

  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final AppNotificationType type;

  @override
  List<Object?> get props => [id, title, body, timeAgo, type];
}
