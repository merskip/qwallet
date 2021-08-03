import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import 'AuthSuite.dart';
import 'GoogleOAuth2.dart';

class GoogleAuthSuite implements AuthSuite {
  final FirebaseAuth firebaseAuth;
  final GoogleOAuth2 googleAuth;

  late final BehaviorSubject<bool> _isSignInSubject;

  GoogleAuthSuite({
    required this.firebaseAuth,
    required this.googleAuth,
  }) {
    _isSignInSubject = BehaviorSubject(
      onListen: () => _refresh(),
    );
  }

  @override
  Stream<bool> isSignIn() {
    return _isSignInSubject.stream;
  }

  @override
  Stream<User> getFirebaseUser() {
    return firebaseAuth
        .authStateChanges()
        .where((user) => user != null)
        .map((user) => user!);
  }

  @override
  Future<Map<String, String>> getAuthHeaders() {
    return googleAuth.getAuthHeaders();
  }

  @override
  Future<void> signInWithGoogle() async {
    final credential = await googleAuth.signIn();
    firebaseAuth.signInWithCredential(credential);
    _refresh();
  }

  @override
  Future<void> signOut() async {
    googleAuth.signOut();
    firebaseAuth.signOut();
    _refresh();
  }

  void _refresh() async {
    final isSignIn = await googleAuth.isSignIn();
    _isSignInSubject.add(isSignIn);
  }
}
