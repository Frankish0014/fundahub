part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.user,
    this.recommended = const [],
    this.errorMessage,
  });

  final HomeStatus status;
  final UserProfile? user;
  final List<Opportunity> recommended;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    UserProfile? user,
    List<Opportunity>? recommended,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      user: user ?? this.user,
      recommended: recommended ?? this.recommended,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, recommended, errorMessage];
}
