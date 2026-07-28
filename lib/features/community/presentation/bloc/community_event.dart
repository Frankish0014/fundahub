part of 'community_bloc.dart';

sealed class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object?> get props => [];
}

class CommunityStarted extends CommunityEvent {
  const CommunityStarted();
}
