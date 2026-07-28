import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../constants/app_constants.dart';

/// Ensures the official FundaHub Platform Super Admin exists in Firebase Auth
/// and Firestore. This is the real ops account used in testing and deployment —
/// not a disposable demo user.
///
/// Uses a secondary Firebase app so any signed-in session is never interrupted.
/// Idempotent: safe on every cold start.
Future<void> ensurePlatformSuperAdmin() async {
  const seedAppName = 'fundahub-super-admin';

  FirebaseApp? seedApp;
  try {
    try {
      seedApp = Firebase.app(seedAppName);
    } catch (_) {
      seedApp = await Firebase.initializeApp(
        name: seedAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final auth = FirebaseAuth.instanceFor(app: seedApp);
    final email = AppConstants.superAdminEmail;
    final password = AppConstants.superAdminPassword;
    User? user;

    try {
      final created = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = created.user;
      if (user != null) {
        await user.updateDisplayName(AppConstants.superAdminName);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') {
        debugPrint('Super admin create skipped: ${error.code}');
        return;
      }
      user = await _signInExistingSuperAdmin(auth, email, password);
    }

    final uid = user?.uid;
    if (uid == null || uid.isEmpty) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fullName': AppConstants.superAdminName,
      'email': email,
      'role': AppConstants.platformAdminRole,
      'isSuperAdmin': true,
      'interests': const <String>[],
      'bio':
          'Official FundaHub Platform Super Admin. Approves and rejects all '
          'provider opportunities and announcements before they reach entrepreneurs.',
      'language': 'en',
      'emailVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await auth.signOut();
    debugPrint('Platform Super Admin ready: $email');
  } catch (error, stack) {
    debugPrint('Platform Super Admin seed failed: $error\n$stack');
  } finally {
    if (seedApp != null) {
      try {
        await seedApp.delete();
      } catch (_) {}
    }
  }
}

Future<User?> _signInExistingSuperAdmin(
  FirebaseAuth auth,
  String email,
  String password,
) async {
  // Prefer the current official password.
  try {
    final result = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  } on FirebaseAuthException {
    // Migrate from the earlier provisional password if that account already exists.
    for (final legacy in AppConstants.superAdminLegacyPasswords) {
      try {
        final result = await auth.signInWithEmailAndPassword(
          email: email,
          password: legacy,
        );
        final user = result.user;
        if (user != null) {
          await user.updatePassword(password);
          await user.updateDisplayName(AppConstants.superAdminName);
        }
        return user;
      } on FirebaseAuthException {
        continue;
      }
    }
    debugPrint(
      'Super admin exists but password could not be verified. '
      'Reset it in Firebase Console to ${AppConstants.superAdminPassword}.',
    );
    return null;
  }
}
