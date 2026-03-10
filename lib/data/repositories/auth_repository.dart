import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:todo_list/core/constants/firebase_constants.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn =
          googleSignIn ??
          GoogleSignIn(serverClientId: kGoogleSignInWebClientId);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign up with email and password.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      throw Exception(messageFromException(e));
    }
  }

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      throw Exception(messageFromException(e));
    }
  }

  /// Sign in with Google. Returns the signed-in [User] or throws.
  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception(_messageGoogleSignInCancelled);
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      final user = _firebaseAuth.currentUser ?? await _waitForAuthUser();
      if (user == null) {
        throw Exception('Sign-in completed but could not get user.');
      }
      return user;
    } catch (e) {
      if (e is FirebaseAuthException) rethrow;
      final message = _messageForGoogleSignInError(e);
      throw Exception(message);
    }
  }

  /// Waits for [authStateChanges] to emit a non-null user (e.g. after sign-in).
  Future<User?> _waitForAuthUser({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) return user;
    try {
      user = await _firebaseAuth
          .authStateChanges()
          .where((u) => u != null)
          .map((u) => u!)
          .first
          .timeout(timeout);
    } catch (_) {
      user = _firebaseAuth.currentUser;
    }
    return user;
  }

  static const String _messageGoogleSignInCancelled =
      'Google sign in was cancelled.';

  static String _messageForGoogleSignInError(Object e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    if (msg == _messageGoogleSignInCancelled) return msg;
    if (msg.contains('sign_in_canceled') ||
        msg.toLowerCase().contains('cancelled')) {
      return _messageGoogleSignInCancelled;
    }
    if (msg.toLowerCase().contains('network') ||
        msg.toLowerCase().contains('connection')) {
      return 'Network error. Check your connection and try again.';
    }
    return msg.isEmpty ? 'Something went wrong. Please try again.' : msg;
  }

  /// Sign out from Firebase and Google.
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  /// Map Firebase auth exceptions to user-friendly messages.
  static String messageFromException(Object e) {
    if (e is FirebaseAuthException) {
      return _messageFromAuthCode(e.code, e.message);
    }
    if (e is PlatformException) {
      final codeStr = e.code;
      final message = e.message;
      if (codeStr.contains('channel-error') ||
          codeStr.contains('pigeon') ||
          (message != null && message.contains('FirebaseAuthHostApi')) ||
          (message != null && message.contains('pigeon'))) {
        return _genericAuthErrorMessage;
      }
      final normalizedCode = codeStr.replaceFirst(RegExp(r'^[\w-]+/'), '');
      final authMessage = _messageFromAuthCode(normalizedCode, message);
      if (authMessage != normalizedCode && authMessage != (message ?? '')) {
        return authMessage;
      }
      if (message != null &&
          message.isNotEmpty &&
          !message.contains('pigeon')) {
        return message;
      }
      return _genericAuthErrorMessage;
    }
    final msg = e.toString().replaceFirst('Exception: ', '');
    if (msg.contains('channel-error') ||
        msg.contains('FirebaseAuthHostApi') ||
        msg.contains('pigeon')) {
      return _genericAuthErrorMessage;
    }
    if (msg == _messageGoogleSignInCancelled) {
      return msg;
    }
    if (msg.contains('sign_in_canceled') ||
        msg.toLowerCase().contains('cancelled')) {
      return _messageGoogleSignInCancelled;
    }
    if (msg.toLowerCase().contains('network') ||
        msg.toLowerCase().contains('connection')) {
      return 'Network error. Check your connection and try again.';
    }
    if (msg.toLowerCase().contains('email-already-in-use') ||
        msg.toLowerCase().contains('email_already_in_use')) {
      return 'An account already exists for this email.';
    }
    if (msg.toLowerCase().contains('weak-password') ||
        msg.toLowerCase().contains('weak_password')) {
      return 'Password should be at least 6 characters.';
    }
    if (msg.toLowerCase().contains('invalid-email') ||
        msg.toLowerCase().contains('invalid_email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.toLowerCase().contains('wrong-password') ||
        msg.toLowerCase().contains('invalid-credential') ||
        msg.toLowerCase().contains('user-not-found')) {
      return 'Invalid email or password.';
    }
    return msg.isEmpty ? _genericAuthErrorMessage : msg;
  }

  static const String _genericAuthErrorMessage =
      'Authentication failed. Please check your details and try again.';

  static String _messageFromAuthCode(String code, String? fallback) {
    switch (code) {
      case 'email-already-in-use':
      case 'email_already_in_use':
        return 'An account already exists for this email.';
      case 'invalid-email':
      case 'invalid_email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
      case 'operation_not_allowed':
        return 'This sign-in method is not enabled.';
      case 'weak-password':
      case 'weak_password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
      case 'user_disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'user_not_found':
      case 'wrong-password':
      case 'wrong_password':
      case 'invalid-credential':
      case 'invalid_credential':
      case 'invalid-login-credentials':
      case 'invalid_login_credentials':
        return 'Invalid email or password.';
      case 'too-many-requests':
      case 'too_many_requests':
        return 'Too many attempts. Try again later.';
      default:
        final trimmed = fallback?.trim() ?? '';
        return trimmed.isNotEmpty ? trimmed : _genericAuthErrorMessage;
    }
  }
}
