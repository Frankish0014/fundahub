import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/current_user_controller.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../../opportunities/domain/usecases/opportunity_usecases.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notifications.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required this.getNotifications,
    required this.currentUser,
    this.getPendingOpportunities,
  }) : super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
  }

  final GetNotifications getNotifications;
  final CurrentUserController currentUser;
  final GetPendingOpportunities? getPendingOpportunities;

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final items = await getNotifications(userId: currentUser.user?.id);
      final merged = <AppNotification>[...items];

      // Super Admin: surface pending opportunity approvals in Notifications.
      if (currentUser.isPlatformAdmin && getPendingOpportunities != null) {
        final pending = await getPendingOpportunities!();
        final approvalItems = pending
            .map(_approvalNotification)
            .toList(growable: false);
        merged.insertAll(0, approvalItems);
      }

      emit(state.copyWith(status: NotificationsStatus.success, items: merged));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  AppNotification _approvalNotification(Opportunity opportunity) {
    final created = opportunity.createdAt;
    return AppNotification(
      id: 'approval-${opportunity.id}',
      title: 'Approval needed: ${opportunity.title}',
      body:
          '${opportunity.organization} submitted a ${opportunity.typeLabel.toLowerCase()} '
          'for verification before it can reach entrepreneurs.',
      timeAgo: _timeAgo(created),
      type: AppNotificationType.moderation,
      createdAt: created,
      moderationStatus: 'pending',
      opportunityId: opportunity.id,
    );
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
