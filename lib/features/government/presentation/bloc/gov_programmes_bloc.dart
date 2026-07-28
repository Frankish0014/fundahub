import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/gov_programme.dart';
import '../../domain/usecases/government_usecases.dart';

part 'gov_programmes_event.dart';
part 'gov_programmes_state.dart';

class GovProgrammesBloc extends Bloc<GovProgrammesEvent, GovProgrammesState> {
  GovProgrammesBloc({required this.getGovProgrammes})
    : super(const GovProgrammesState()) {
    on<GovProgrammesStarted>(_onStarted);
    on<GovProgrammesCategorySelected>(_onCategorySelected);
  }

  final GetGovProgrammes getGovProgrammes;

  Future<void> _onStarted(
    GovProgrammesStarted event,
    Emitter<GovProgrammesState> emit,
  ) => _load(emit, state.category);

  Future<void> _onCategorySelected(
    GovProgrammesCategorySelected event,
    Emitter<GovProgrammesState> emit,
  ) => _load(emit, event.category);

  Future<void> _load(Emitter<GovProgrammesState> emit, String category) async {
    emit(
      state.copyWith(status: GovProgrammesStatus.loading, category: category),
    );
    try {
      final items = await getGovProgrammes(category: category);
      emit(
        state.copyWith(status: GovProgrammesStatus.success, programmes: items),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GovProgrammesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
