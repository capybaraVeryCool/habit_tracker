import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habeats/domain/models/user.dart' as app_user;

class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // Cache for the current user
  app_user.User? _cachedUser;

  AuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance {
    // Listen to auth state changes and update the cached user
    _firebaseAuth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _cachedUser = null;
      } else {
        _cachedUser = _createAppUserFromFirebaseUser(firebaseUser);
      }
    });
  }

  Stream<app_user.User?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _createAppUserFromFirebaseUser(firebaseUser);
    });
  }

  // Synchronous getter for the current user
  app_user.User? get currentUser => _cachedUser;

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final currentUser = _createAppUserFromFirebaseUser(firebaseUser);
        await _firestore
            .collection('users')
            .doc(currentUser.id)
            .set(currentUser.toJson());
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Update _cachedUser directly after successful login
        _cachedUser = _createAppUserFromFirebaseUser(firebaseUser);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Exception _handleAuthError(dynamic e) {
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('Email is already in use.');
        default:
          return Exception(e.message ?? 'Authentication failed.');
      }
    }
    return Exception('Something went wrong.');
  }

  // Helper function to create an app_user.User from a Firebase User
  app_user.User _createAppUserFromFirebaseUser(
      firebase_auth.User firebaseUser) {
    return app_user.User(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName:
          firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
      lastSyncTime: DateTime.now(),
      // Add default values for other fields if needed
      totalXp: 0,
      level: 1,
      badges: [],
    );
  }
}
