import 'package:equatable/equatable.dart';

class TrainingPath extends Equatable {
  const TrainingPath({
    required this.id,
    required this.badge,
    required this.title,
    required this.body,
    this.lessons = 0,
  });

  final String id;
  final String badge;
  final String title;
  final String body;
  final int lessons;

  @override
  List<Object?> get props => [id, badge, title, body, lessons];
}
