import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/current_user_controller.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.getCurrentUser,
    required this.currentUser,
  }) : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileUserSynced>(_onUserSynced);
    currentUser.addListener(_onExternalUserChange);
  }

  final GetCurrentUser getCurrentUser;
  final CurrentUserController currentUser;

  void _onExternalUserChange() {
    add(ProfileUserSynced(currentUser.user));
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await getCurrentUser();
      if (user == null) {
        emit(
          const ProfileState(
            status: ProfileStatus.failure,
            errorMessage: 'Please sign in to view your profile.',
          ),
        );
        return;
      }
      currentUser.apply(user);
      emit(ProfileState(status: ProfileStatus.success, user: user));
    } catch (e) {
      emit(
        ProfileState(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onUserSynced(ProfileUserSynced event, Emitter<ProfileState> emit) {
    if (event.user == null) {
      emit(
        const ProfileState(
          status: ProfileStatus.failure,
          errorMessage: 'Please sign in to view your profile.',
        ),
      );
      return;
    }
    emit(ProfileState(status: ProfileStatus.success, user: event.user));
  }

  @override
  Future<void> close() {
    currentUser.removeListener(_onExternalUserChange);
    return super.close();
  }
}
