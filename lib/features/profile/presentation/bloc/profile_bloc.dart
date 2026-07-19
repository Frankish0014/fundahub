import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this.getCurrentUser}) : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
  }

  final GetCurrentUser getCurrentUser;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await getCurrentUser();
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          user:
              user ??
              const UserProfile(
                id: 'demo',
                fullName: 'Andrew',
                email: 'andrew@fundahub.app',
                role: 'Student Entrepreneur',
                interests: ['Tech', 'Education', 'Seed Funding'],
              ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
