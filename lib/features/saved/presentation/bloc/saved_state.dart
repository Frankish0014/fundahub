part of 'saved_bloc.dart';

enum SavedStatus { initial, loading, success, failure }

class SavedState extends Equatable {
  const SavedState({
    this.status = SavedStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final SavedStatus status;
  final List<Opportunity> items;
  final String? errorMessage;

  SavedState copyWith({
    SavedStatus? status,
    List<Opportunity>? items,
    String? errorMessage,
  }) {
    return SavedState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
