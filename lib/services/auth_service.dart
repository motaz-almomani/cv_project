import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  AuthService({GlobalKey<NavigatorState>? navigatorKey}) : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState>? _navigatorKey;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found for this email address.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'invalid-credential':
          return 'Invalid email or password.';
        default:
          return 'Sign-in failed: ${e.message ?? e.code}';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'Registration failed: ${e.message ?? e.code}';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final nav = _navigatorKey?.currentState;
    if (nav != null && nav.mounted) {
      nav.popUntil((route) => route.isFirst);
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<String?> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) return 'Not signed in.';
    final trimmed = displayName.trim();
    try {
      if (trimmed.isEmpty) {
        await user.updateDisplayName(null);
      } else {
        await user.updateDisplayName(trimmed);
      }
      await user.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not update display name.';
    } catch (e) {
      return 'Could not update display name.';
    }
  }

  /// Requires current password for re-authentication.
  Future<String?> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return 'Not signed in.';
    final email = user.email;
    if (email == null) return 'No email is linked to this account.';
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'Current password is incorrect.';
        case 'weak-password':
          return 'New password is too weak. Use at least 6 characters.';
        default:
          return e.message ?? 'Could not update password.';
      }
    } catch (e) {
      return 'Could not update password.';
    }
  }

  Future<String?> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return 'Not signed in.';
    if (user.emailVerified) return null;
    try {
      await user.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not send verification email.';
    } catch (e) {
      return 'Could not send verification email.';
    }
  }
}

