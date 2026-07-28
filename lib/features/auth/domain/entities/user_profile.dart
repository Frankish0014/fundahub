import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.interests = const [],
    this.emailVerified = false,
    this.bio = '',
    this.photoUrl,
    this.language = 'en',
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final List<String> interests;
  final bool emailVerified;
  final String bio;
  final String? photoUrl;
  final String language;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  String get initial =>
      fullName.isEmpty ? '?' : fullName.trim()[0].toUpperCase();

  bool get isOpportunityProvider =>
      role == 'NGO / Organisation' || role == 'Government Partner';

  bool get isPlatformAdmin => role == 'Platform Admin';

  /// Alias: Platform Admin is the application Super Admin.
  bool get isSuperAdmin => isPlatformAdmin;

  /// Providers + admins (hub / publish tooling access).
  bool get canPublishContent => isOpportunityProvider || isPlatformAdmin;

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? role,
    List<String>? interests,
    bool? emailVerified,
    String? bio,
    String? photoUrl,
    String? language,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      interests: interests ?? this.interests,
      emailVerified: emailVerified ?? this.emailVerified,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    role,
    interests,
    emailVerified,
    bio,
    photoUrl,
    language,
  ];
}
