import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase anonymous authentication for online mode.
///
/// This service avoids creating multiple anonymous users by reusing
/// the existing authenticated user when available.
class FirebaseAuthService {
  FirebaseAuthService._(this._auth);

  static final FirebaseAuthService instance =
      FirebaseAuthService._(FirebaseAuth.instance);

  /// Test-only constructor accepting an injected [FirebaseAuth] fake.
  @visibleForTesting
  FirebaseAuthService.forTesting(this._auth);

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  String? get currentUid => _auth.currentUser?.uid;

  bool get isAuthenticated => _auth.currentUser != null;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Returns the existing signed-in user or creates a new anonymous user.
  ///
  /// Never creates a second anonymous user while one already exists.
  Future<User?> ensureAnonymousSignIn() async {
    final existing = _auth.currentUser;
    if (existing != null) {
      return existing;
    }

    final credential = await _auth.signInAnonymously();
    return credential.user;
  }

  /// Ensures an anonymous user exists and returns a stable UID for online
  /// operations. Throws when authentication cannot be established.
  Future<String> requireUid() async {
    final user = await ensureAnonymousSignIn();
    if (user == null) {
      throw Exception('Failed to authenticate with Firebase');
    }
    return user.uid;
  }
}
