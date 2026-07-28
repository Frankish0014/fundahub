part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileUserSynced extends ProfileEvent {
  const ProfileUserSynced(this.user);

  final UserProfile? user;

  @override
  List<Object?> get props => [user];
}
