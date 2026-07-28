import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fundahub/app.dart';
import 'package:fundahub/features/auth/domain/entities/user_profile.dart';
import 'package:fundahub/features/auth/domain/repositories/auth_repository.dart';
import 'package:fundahub/injection/injection.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies(
      authRepositoryOverride: _TestAuthRepository(),
      firestoreOverride: FakeFirebaseFirestore(),
    );
  });

  testWidgets('Welcome screen shows FundaHub brand', (tester) async {
    await tester.pumpWidget(const FundaHubApp());
    await tester.pumpAndSettle();

    expect(find.text('FundaHub'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}

class _TestAuthRepository implements AuthRepository {
  @override
  Future<UserProfile?> getCurrentUser() async => null;

  @override
  Future<bool> hasCompletedOnboarding() async => false;

  @override
  Future<void> setOnboardingCompleted(bool value) async {}

  @override
  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) => throw UnimplementedError();

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<UserProfile> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String role,
    String? bio,
    String? photoUrl,
    String? language,
  }) => throw UnimplementedError();

  @override
  Future<UserProfile> updateInterests(List<String> interests) =>
      throw UnimplementedError();

  @override
  Future<UserProfile> uploadProfilePhoto({
    required List<int> bytes,
    required String fileName,
  }) => throw UnimplementedError();

  @override
  Future<void> logout() async {}
}
