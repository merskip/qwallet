import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthSuite {
  Stream<bool> isSignIn();

  Stream<User> getFirebaseUser();

  Future<Map<String, String>> getAuthHeaders();

  Future<void> signInWithGoogle();

  Future<void> signOut();
}
