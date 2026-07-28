import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/community_post.dart';
import '../../domain/usecases/community_usecases.dart';

part 'community_event.dart';
part 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc({required this.getCommunityPosts})
    : super(const CommunityState()) {
    on<CommunityStarted>(_onStarted);
  }

  final GetCommunityPosts getCommunityPosts;

  Future<void> _onStarted(
    CommunityStarted event,
    Emitter<CommunityState> emit,
  ) async {
    emit(state.copyWith(status: CommunityStatus.loading));
    try {
      final posts = await getCommunityPosts();
      emit(state.copyWith(status: CommunityStatus.success, posts: posts));
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
