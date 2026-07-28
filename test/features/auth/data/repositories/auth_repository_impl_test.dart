import 'package:flutter_test/flutter_test.dart';
import 'package:fundahub/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fundahub/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fundahub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late _FakeAuthRemoteDataSource remote;
  late AuthLocalDataSource local;
  late AuthRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    remote = _FakeAuthRemoteDataSource();
    local = AuthLocalDataSource(await SharedPreferences.getInstance());
    repository = AuthRepositoryImpl(remote, local);
  });

  test('registers with Firebase and stores the local profile', () async {
    remote.nextUser = const RemoteAuthUser(
      id: 'uid-1',
      email: 'tifare@example.com',
      displayName: 'Tifare Kaseke',
      emailVerified: false,
    );

    final user = await repository.register(
      fullName: 'Tifare Kaseke',
      email: 'tifare@example.com',
      password: 'Password123',
      role: 'Student Entrepreneur',
    );

    expect(remote.registerCalls, 1);
    expect(user.id, 'uid-1');
    expect(user.role, 'Student Entrepreneur');
    expect((await local.getCurrentUser())?.email, 'tifare@example.com');
  });

  test('restores an authenticated Firebase session after restart', () async {
    await local.saveUser(
      id: 'uid-2',
      fullName: 'Tifare Kaseke',
      email: 'tifare@example.com',
      role: 'Founder',
      interests: const ['Technology'],
    );
    remote.currentUser = const RemoteAuthUser(
      id: 'uid-2',
      email: 'tifare@example.com',
      displayName: 'Tifare Kaseke',
      emailVerified: true,
    );

    final user = await repository.getCurrentUser();

    expect(user, isNotNull);
    expect(user!.role, 'Founder');
    expect(user.interests, const ['Technology']);
    expect(user.emailVerified, isTrue);
  });

  test('creates a sensible profile after Google sign-in', () async {
    remote.nextUser = const RemoteAuthUser(
      id: 'google-uid',
      email: 'tifare.kaseke@gmail.com',
      displayName: 'Tifare Kaseke',
      emailVerified: true,
    );

    final user = await repository.signInWithGoogle();

    expect(remote.googleCalls, 1);
    expect(user.fullName, 'Tifare Kaseke');
    expect(user.role, 'Entrepreneur');
    expect(user.emailVerified, isTrue);
  });

  test('logout signs out remotely and clears the cached profile', () async {
    await local.saveUser(
      id: 'uid-3',
      fullName: 'Tifare Kaseke',
      email: 'tifare@example.com',
      role: 'Founder',
    );

    await repository.logout();

    expect(remote.logoutCalls, 1);
    expect(await repository.getCurrentUser(), isNull);
  });

  test('sends a password reset request through Firebase', () async {
    await repository.sendPasswordResetEmail('tifare@example.com');

    expect(remote.lastResetEmail, 'tifare@example.com');
  });
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  RemoteAuthUser? currentUser;
  RemoteAuthUser? nextUser;
  int registerCalls = 0;
  int googleCalls = 0;
  int logoutCalls = 0;
  String? lastResetEmail;

  @override
  Future<RemoteAuthUser?> getCurrentUser() async => currentUser;

  @override
  Future<RemoteAuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    registerCalls++;
    return _requiredNextUser();
  }

  @override
  Future<RemoteAuthUser> login({
    required String email,
    required String password,
  }) async => _requiredNextUser();

  @override
  Future<RemoteAuthUser> signInWithGoogle() async {
    googleCalls++;
    return _requiredNextUser();
  }

  @override
  Future<RemoteAuthUser> updateDisplayName(String fullName) async =>
      _requiredNextUser();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    lastResetEmail = email;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    currentUser = null;
  }

  RemoteAuthUser _requiredNextUser() {
    final user = nextUser;
    if (user == null) throw StateError('Set nextUser before this test.');
    currentUser = user;
    return user;
  }
}
