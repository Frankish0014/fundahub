import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../../opportunities/domain/usecases/opportunity_usecases.dart';

part 'saved_event.dart';
part 'saved_state.dart';

class SavedBloc extends Bloc<SavedEvent, SavedState> {
  SavedBloc({required this.getSaved, required this.getCurrentUser})
    : super(const SavedState()) {
    on<SavedStarted>(_onStarted);
  }

  final GetSavedOpportunities getSaved;
  final GetCurrentUser getCurrentUser;

  Future<void> _onStarted(SavedStarted event, Emitter<SavedState> emit) async {
    emit(state.copyWith(status: SavedStatus.loading));
    try {
      final user = await getCurrentUser();
      if (user == null) {
        emit(state.copyWith(status: SavedStatus.success, items: const []));
        return;
      }
      final items = await getSaved(userId: user.id);
      emit(state.copyWith(status: SavedStatus.success, items: items));
    } catch (e) {
      emit(
        state.copyWith(status: SavedStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
