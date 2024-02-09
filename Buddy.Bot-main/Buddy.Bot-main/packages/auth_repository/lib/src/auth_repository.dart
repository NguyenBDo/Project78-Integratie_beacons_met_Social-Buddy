import 'dart:async';

import 'package:auth_repository/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as db;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

/// A typedef alias for a Firebase user.
typedef FirebaseUser = auth.User;

/// {@template auth_repository}
/// A repository responsible for managing authentication.
/// {@endtemplate}
class AuthRepository {
  /// {@macro auth_repository}
  AuthRepository() {
    _startAuthSubscription();
  }

  auth.FirebaseAuth get _auth => auth.FirebaseAuth.instance;
  db.FirebaseFirestore get _db => db.FirebaseFirestore.instance;

  final _currentUser = BehaviorSubject<User?>.seeded(null);

  late StreamSubscription<FirebaseUser?> _authSubscription;
  StreamSubscription<db.DocumentSnapshot<Map<String, dynamic>>>?
      _dbSubscription;

  static const _usersCollection = 'bots';

  void _startAuthSubscription() {
    _authSubscription = _auth.authStateChanges().listen((fbUser) async {
      await _dbSubscription?.cancel();

      if (fbUser == null) {
        _currentUser.add(null);
      } else {
        await _createUserIfNotExists(fbUser);
        _subscribeToUserDoc(fbUser);
      }
    });
  }

  Future<void> _createUserIfNotExists(FirebaseUser fbUser) async {
    final newUser = User(
      id: fbUser.uid,
      emailAddress: fbUser.email,
    );

    final userDoc = _db.collection(_usersCollection).doc(fbUser.email);
    await userDoc.set(newUser.toJson(), db.SetOptions(merge: true));
  }

  void _subscribeToUserDoc(FirebaseUser fbUser) {
    _dbSubscription = _db
        .collection(_usersCollection)
        .doc(fbUser.email)
        .snapshots()
        .listen((snapshot) {
      final user = User(
        id: snapshot.id,
        emailAddress: fbUser.email,
      );
      _currentUser.add(user);
    });
  }

  /// A stream of the current user.
  ///
  /// Can be listened to, but the current value can also be retrieved using
  /// `currentUser.value`.
  ValueStream<User?> get currentUser => _currentUser.stream;

  /// Indicates whether a user is currently signed in.
  bool get isSignedIn => currentUser.valueOrNull != null;

  /// Signs a new user in through Google.
  ///
  /// Returns a [Future] that completes with the [User] if the sign in is
  /// successful, or `null` otherwise. The [currentUser] stream will also be
  /// updated upon success.
  ///
  /// Throws an error if a user is already signed in.
  Future<User?> signInWithGoogle() async {
    if (isSignedIn) {
      throw StateError('A user is already signed in.');
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return null;
    }

    final googleAuth = await googleUser.authentication;
    final credential = auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final authUser = userCredential.user;
    if (authUser == null) {
      return null;
    }

    return _currentUser.firstWhere((user) => user != null);
  }

  /// Disposes the repository.
  void dispose() {
    _authSubscription.cancel();
  }
}
