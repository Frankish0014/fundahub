part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

class HomeUserSynced extends HomeEvent {
  const HomeUserSynced(this.user);

  final UserProfile? user;

  @override
  List<Object?> get props => [user];
}
