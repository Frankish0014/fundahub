import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../../opportunities/domain/usecases/opportunity_usecases.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.getCurrentUser, required this.getRecommended})
    : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  final GetCurrentUser getCurrentUser;
  final GetRecommendedOpportunities getRecommended;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final user = await getCurrentUser();
      final recommended = await getRecommended();
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
}
