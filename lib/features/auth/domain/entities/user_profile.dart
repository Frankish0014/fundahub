import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.interests = const [],
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final List<String> interests;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  String get initial =>
      fullName.isEmpty ? '?' : fullName.trim()[0].toUpperCase();

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? role,
    List<String>? interests,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      interests: interests ?? this.interests,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, role, interests];
}
