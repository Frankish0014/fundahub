import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notifications.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({required this.getNotifications})
    : super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
  }

  final GetNotifications getNotifications;

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final items = await getNotifications();
      emit(state.copyWith(status: NotificationsStatus.success, items: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
