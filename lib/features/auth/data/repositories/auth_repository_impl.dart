import '../../domain/entities/user_profile.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<UserProfile?> getCurrentUser() async {
    final remoteUser = await _remote.getCurrentUser();
    if (remoteUser == null) return null;
    return _profileFromRemote(remoteUser);
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
    return _local.saveUser(
      id: remoteUser.id,
      fullName: fullName,
      email: remoteUser.email,
      role: role,
      emailVerified: remoteUser.emailVerified,
    );
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final remoteUser = await _remote.login(email: email, password: password);
    return _profileFromRemote(remoteUser);
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    final remoteUser = await _remote.signInWithGoogle();
    return _profileFromRemote(remoteUser);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _remote.sendPasswordResetEmail(email);

  @override
  Future<UserProfile> updateInterests(List<String> interests) =>
      _local.updateInterests(interests);

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String role,
  }) async {
    final existing = await getCurrentUser();
    if (existing == null) {
      throw const AuthFailure('You must be logged in to update your profile.');
    }
    final remoteUser = await _remote.updateDisplayName(fullName);
    return _local.saveUser(
      id: remoteUser.id,
      fullName: fullName,
      email: remoteUser.email,
      role: role,
      interests: existing.interests,
      emailVerified: remoteUser.emailVerified,
    );
  }

  @override
  Future<void> logout() async {
    await _remote.logout();
    await _local.clearSession();
  }

  Future<UserProfile> _profileFromRemote(RemoteAuthUser remoteUser) async {
    final localUser = await _local.getCurrentUser();

    late final String fullName;
    late final String role;
    late final List<String> interests;
    if (localUser != null && localUser.id == remoteUser.id) {
      fullName = localUser.fullName.trim().isNotEmpty
          ? localUser.fullName
          : remoteUser.displayName.trim().isNotEmpty
          ? remoteUser.displayName.trim()
          : _nameFromEmail(remoteUser.email);
      role = localUser.role;
      interests = localUser.interests;
    } else {
      fullName = remoteUser.displayName.trim().isNotEmpty
          ? remoteUser.displayName.trim()
          : _nameFromEmail(remoteUser.email);
      role = 'Entrepreneur';
      interests = const <String>[];
    }

    return _local.saveUser(
      id: remoteUser.id,
      fullName: fullName,
      email: remoteUser.email,
      role: role,
      interests: interests,
      emailVerified: remoteUser.emailVerified,
    );
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
