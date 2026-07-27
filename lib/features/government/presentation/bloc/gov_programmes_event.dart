part of 'gov_programmes_bloc.dart';

sealed class GovProgrammesEvent extends Equatable {
  const GovProgrammesEvent();

  @override
  List<Object?> get props => [];
}

class GovProgrammesStarted extends GovProgrammesEvent {
  const GovProgrammesStarted();
}

class GovProgrammesCategorySelected extends GovProgrammesEvent {
  const GovProgrammesCategorySelected(this.category);

  final String category;

  @override
  List<Object?> get props => [category];
}
