part of 'gov_programmes_bloc.dart';

enum GovProgrammesStatus { initial, loading, success, failure }

class GovProgrammesState extends Equatable {
  const GovProgrammesState({
    this.status = GovProgrammesStatus.initial,
    this.programmes = const [],
    this.category = 'All Programs',
    this.errorMessage,
  });

  final GovProgrammesStatus status;
  final List<GovProgramme> programmes;
  final String category;
  final String? errorMessage;

  GovProgrammesState copyWith({
    GovProgrammesStatus? status,
    List<GovProgramme>? programmes,
    String? category,
    String? errorMessage,
  }) {
    return GovProgrammesState(
      status: status ?? this.status,
      programmes: programmes ?? this.programmes,
      category: category ?? this.category,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, programmes, category, errorMessage];
}
