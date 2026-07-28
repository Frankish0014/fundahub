import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../../opportunities/domain/usecases/opportunity_usecases.dart';
import '../../../../core/session/current_user_controller.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required this.getCurrentUser,
    required this.getRecommended,
    required this.currentUser,
  }) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onStarted);
    on<HomeUserSynced>(_onUserSynced);
    currentUser.addListener(_onExternalUserChange);
  }

  final GetCurrentUser getCurrentUser;
  final GetRecommendedOpportunities getRecommended;
  final CurrentUserController currentUser;

  void _onExternalUserChange() {
    add(HomeUserSynced(currentUser.user));
  }

  Future<void> _onStarted(HomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final user = await getCurrentUser();
      if (user != null) currentUser.apply(user);
      final recommended = await getRecommended(
        interests: user?.interests ?? const [],
        role: user?.role,
        userId: user?.id,
      );
      emit(
        state.copyWith(
          status: HomeStatus.success,
          user: user,
          recommended: recommended,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void _onUserSynced(HomeUserSynced event, Emitter<HomeState> emit) {
    if (state.user == event.user) return;
    emit(state.copyWith(user: event.user));
  }

  @override
  Future<void> close() {
    currentUser.removeListener(_onExternalUserChange);
    return super.close();
  }
}
