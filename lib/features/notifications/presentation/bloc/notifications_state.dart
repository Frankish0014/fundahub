part of 'notifications_bloc.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<AppNotification> items;
  final String? errorMessage;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
