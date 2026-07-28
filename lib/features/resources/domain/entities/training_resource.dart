import 'package:equatable/equatable.dart';

/// A heading + paragraph block within a resource article.
class ResourceSection extends Equatable {
  const ResourceSection({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  List<Object?> get props => [heading, body];
}

class TrainingResource extends Equatable {
  const TrainingResource({
    required this.id,
    required this.category,
    required this.title,
    this.readTime = '',
    this.excerpt = '',
    this.author = '',
    this.authorRole = '',
    this.intro = '',
    this.sections = const [],
    this.quote = '',
  });

  final String id;
  final String category;
  final String title;
  final String readTime;
  final String excerpt;
  final String author;
  final String authorRole;
  final String intro;
  final List<ResourceSection> sections;
  final String quote;

  @override
  List<Object?> get props => [
    id,
    category,
    title,
    readTime,
    excerpt,
    author,
    authorRole,
    intro,
    sections,
    quote,
  ];
}
