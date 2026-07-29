import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/session/current_user_controller.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remote,
    this._local, {
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    CurrentUserController? currentUser,
  }) : _firestore = firestore,
       _storage = storage,
       _currentUser = currentUser;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final CurrentUserController? _currentUser;

  UserProfile? _memoryProfile;
  String? _memoryUid;

  CollectionReference<Map<String, dynamic>>? get _users =>
      _firestore?.collection('users');

  @override
  Future<UserProfile?> getCurrentUser() async {
    final remoteUser = await _remote.getCurrentUser();
    if (remoteUser == null) {
      _memoryProfile = null;
      _memoryUid = null;
      _currentUser?.clear();
      return null;
    }

    // Fast path: warm in-memory profile for the same uid (tab switches / blocs).
    if (_memoryProfile != null && _memoryUid == remoteUser.id) {
      _currentUser?.apply(_memoryProfile);
      return _memoryProfile;
    }

    // Prefer local SharedPreferences before hitting Firestore, but always
    // reconcile emailVerified against the live Firebase Auth value so a user
    // who just verified their email doesn't have to log out/in to see it.
    final localUser = await _local.getCurrentUser();
    if (localUser != null && localUser.id == remoteUser.id) {
      final profile = localUser.emailVerified == remoteUser.emailVerified
          ? localUser
          : localUser.copyWith(emailVerified: remoteUser.emailVerified);
      _cacheProfile(profile);
      return profile;
    }

    final profile = await _profileFromRemote(remoteUser);
    _cacheProfile(profile);
    return profile;
  }

  void _cacheProfile(UserProfile profile) {
    _memoryProfile = profile;
    _memoryUid = profile.id;
    _currentUser?.apply(profile);
  }

  @override
  Future<bool> hasCompletedOnboarding() => _local.hasCompletedOnboarding();

  @override
  Future<void> setOnboardingCompleted(bool value) =>
      _local.setOnboardingCompleted(value);

  @override
  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final remoteUser = await _remote.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    final profile = await _local.saveUser(
      id: remoteUser.id,
      fullName: fullName,
      email: remoteUser.email,
      role: role,
      emailVerified: remoteUser.emailVerified,
    );
    await _syncUserDoc(profile);
    _cacheProfile(profile);
    return profile;
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final remoteUser = await _remote.login(email: email, password: password);
    final profile = await _profileFromRemote(remoteUser);
    _cacheProfile(profile);
    return profile;
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    final remoteUser = await _remote.signInWithGoogle();
    final profile = await _profileFromRemote(remoteUser);
    _cacheProfile(profile);
    return profile;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _remote.sendPasswordResetEmail(email);

  @override
  Future<UserProfile> updateInterests(List<String> interests) async {
    final updated = await _local.updateInterests(interests);
    await _syncUserDoc(updated);
    _cacheProfile(updated);
    return updated;
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String role,
    String? bio,
    String? photoUrl,
    String? language,
  }) async {
    final existing = await getCurrentUser();
    if (existing == null) {
      throw const AuthFailure('You must be logged in to update your profile.');
    }
    final remoteUser = await _remote.updateDisplayName(fullName);
    final profile = await _local.saveUser(
      id: remoteUser.id,
      fullName: fullName,
      email: remoteUser.email,
      role: role,
      interests: existing.interests,
      emailVerified: remoteUser.emailVerified,
      bio: bio ?? existing.bio,
      photoUrl: photoUrl ?? existing.photoUrl,
      language: language ?? existing.language,
    );
    await _syncUserDoc(profile);
    _cacheProfile(profile);
    return profile;
  }

  @override
  Future<UserProfile> uploadProfilePhoto({
    required List<int> bytes,
    required String fileName,
  }) async {
    final existing = await getCurrentUser();
    if (existing == null) {
      throw const AuthFailure('You must be logged in to upload a photo.');
    }
    if (bytes.isEmpty) {
      throw const AuthFailure('Selected image is empty.');
    }

    // Chrome/web often blocks Storage uploads until bucket CORS is configured.
    // Store a compact data URL in Firestore so profile photos work on web (CORS).
    if (kIsWeb) {
      return _uploadProfilePhotoEmbedded(existing, bytes);
    }

    final storage = _storage;
    if (storage == null) {
      return _uploadProfilePhotoEmbedded(existing, bytes);
    }

    try {
      return await _uploadProfilePhotoToStorage(
        existing,
        bytes,
        fileName,
        storage,
      );
    } on FirebaseException {
      return _uploadProfilePhotoEmbedded(existing, bytes);
    } catch (_) {
      return _uploadProfilePhotoEmbedded(existing, bytes);
    }
  }

  Future<UserProfile> _uploadProfilePhotoToStorage(
    UserProfile existing,
    List<int> bytes,
    String fileName,
    FirebaseStorage storage,
  ) async {
    final ref = storage.ref().child('profile_photos/${existing.id}/$fileName');
    await ref
        .putData(
          Uint8List.fromList(bytes),
          SettableMetadata(contentType: 'image/jpeg'),
        )
        .timeout(const Duration(seconds: 25));
    final url = await ref.getDownloadURL().timeout(const Duration(seconds: 10));
    return updateProfile(
      fullName: existing.fullName,
      role: existing.role,
      bio: existing.bio,
      photoUrl: url,
      language: existing.language,
    );
  }

  Future<UserProfile> _uploadProfilePhotoEmbedded(
    UserProfile existing,
    List<int> bytes,
  ) async {
    if (bytes.length > 900000) {
      throw const AuthFailure(
        'Image is too large. Choose a smaller photo (under 1 MB).',
      );
    }

    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    final profile = await _local.saveUser(
      id: existing.id,
      fullName: existing.fullName,
      email: existing.email,
      role: existing.role,
      interests: existing.interests,
      emailVerified: existing.emailVerified,
      bio: existing.bio,
      photoUrl: dataUrl,
      language: existing.language,
    );
    await _syncUserDoc(profile);
    _cacheProfile(profile);
    return profile;
  }

  @override
  Future<void> logout() async {
    await _remote.logout();
    await _local.clearSession();
    _memoryProfile = null;
    _memoryUid = null;
    _currentUser?.clear();
  }

  Future<UserProfile> _profileFromRemote(RemoteAuthUser remoteUser) async {
    final localUser = await _local.getCurrentUser();
    Map<String, dynamic>? remoteData;
    try {
      final users = _users;
      if (users != null) {
        remoteData = (await users.doc(remoteUser.id).get()).data();
      }
    } catch (_) {
      remoteData = null;
    }

    late final String fullName;
    late final String role;
    late final List<String> interests;
    late final String bio;
    late final String? photoUrl;
    late final String language;

    if (localUser != null && localUser.id == remoteUser.id) {
      fullName = localUser.fullName.trim().isNotEmpty
          ? localUser.fullName
          : remoteUser.displayName.trim().isNotEmpty
          ? remoteUser.displayName.trim()
          : _nameFromEmail(remoteUser.email);
      role = (remoteData?['role'] as String?)?.trim().isNotEmpty == true
          ? remoteData!['role'] as String
          : localUser.role;
      interests = localUser.interests.isNotEmpty
          ? localUser.interests
          : List<String>.from(remoteData?['interests'] as List? ?? const []);
      bio = localUser.bio.isNotEmpty
          ? localUser.bio
          : (remoteData?['bio'] as String? ?? '');
      photoUrl = localUser.photoUrl ?? remoteData?['photoUrl'] as String?;
      language = localUser.language.isNotEmpty
          ? localUser.language
          : (remoteData?['language'] as String? ?? 'en');
    } else if (remoteData != null) {
      fullName = (remoteData['fullName'] as String?)?.trim().isNotEmpty == true
          ? remoteData['fullName'] as String
          : remoteUser.displayName.trim().isNotEmpty
          ? remoteUser.displayName.trim()
          : _nameFromEmail(remoteUser.email);
      role = (remoteData['role'] as String?) ?? 'Student Entrepreneur';
      interests = List<String>.from(
        remoteData['interests'] as List? ?? const [],
      );
      bio = remoteData['bio'] as String? ?? '';
      photoUrl = remoteData['photoUrl'] as String?;
      language = remoteData['language'] as String? ?? 'en';
    } else {
      fullName = remoteUser.displayName.trim().isNotEmpty
          ? remoteUser.displayName.trim()
          : _nameFromEmail(remoteUser.email);
      role = 'Student Entrepreneur';
      interests = const <String>[];
      bio = '';
      photoUrl = null;
      language = 'en';
    }

    final profile = await _local.saveUser(
      id: remoteUser.id,
      fullName: fullName,
      email: remoteUser.email,
      role: role,
      interests: interests,
      emailVerified: remoteUser.emailVerified,
      bio: bio,
      photoUrl: photoUrl,
      language: language,
    );
    // Persist to Firestore in the background — don't block UI on reads.
    unawaited(_syncUserDoc(profile));
    return profile;
  }

  Future<void> _syncUserDoc(UserProfile profile) async {
    final users = _users;
    if (users == null) return;
    try {
      await users.doc(profile.id).set({
        'fullName': profile.fullName,
        'email': profile.email,
        'role': profile.role,
        'interests': profile.interests,
        'bio': profile.bio,
        'photoUrl': profile.photoUrl,
        'language': profile.language,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  String _nameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) return 'FundaHub User';
    return localPart
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
