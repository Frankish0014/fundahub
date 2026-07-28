import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/errors/auth_failure.dart';

class RemoteAuthUser {
  const RemoteAuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.emailVerified,
  });

  final String id;
  final String email;
  final String displayName;
  final bool emailVerified;
}

abstract interface class AuthRemoteDataSource {
  Future<RemoteAuthUser?> getCurrentUser();

  Future<RemoteAuthUser> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<RemoteAuthUser> login({
    required String email,
    required String password,
  });

  Future<RemoteAuthUser> signInWithGoogle();

  Future<RemoteAuthUser> updateDisplayName(String fullName);

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource(this._firebaseAuth, this._googleSignIn);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<RemoteAuthUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Future<RemoteAuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _requireUser(credential.user);
      await user.updateDisplayName(fullName);
      await user.sendEmailVerification();
      await user.reload();
      return _mapUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_firebaseMessage(error));
    }
  }

  @override
  Future<RemoteAuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapUser(_requireUser(credential.user));
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_firebaseMessage(error));
    }
  }

  @override
  Future<RemoteAuthUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      final googleAuthentication = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return _mapUser(_requireUser(userCredential.user));
    } on GoogleSignInException catch (error) {
      throw AuthFailure(_googleMessage(error));
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_firebaseMessage(error));
    }
  }

  @override
  Future<RemoteAuthUser> updateDisplayName(String fullName) async {
    try {
      final user = _requireUser(_firebaseAuth.currentUser);
      await user.updateDisplayName(fullName);
      await user.reload();
      return _mapUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_firebaseMessage(error));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_firebaseMessage(error));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_firebaseMessage(error));
    }

    try {
      await _googleSignIn.signOut();
    } on Object {
      // Firebase is already signed out. A stale provider session should not
      // keep the user inside the app or make the logout button appear broken.
    }
  }

  User _requireUser(User? user) {
    if (user == null) {
      throw const AuthFailure('Authentication did not return a user account.');
    }
    return user;
  }

  RemoteAuthUser _mapUser(User user) {
    return RemoteAuthUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      emailVerified: user.emailVerified,
    );
  }

  String _googleMessage(GoogleSignInException error) {
    if (error.code == GoogleSignInExceptionCode.canceled) {
      return 'Google sign-in was cancelled.';
    }
    if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
      return 'Google sign-in is not configured correctly. Check the SHA keys and Web client ID in Firebase.';
    }
    return 'Google sign-in could not be completed. Please try again.';
  }

  String _firebaseMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Please enter a valid email address.',
      'email-already-in-use' =>
        'An account already exists with this email address.',
      'weak-password' => 'Use a stronger password with at least 8 characters.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'The email or password is incorrect.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'No internet connection. Check your connection and try again.',
      'operation-not-allowed' =>
        'This sign-in method has not been enabled in Firebase.',
      'account-exists-with-different-credential' =>
        'An account already exists with this email using another sign-in method.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
}
