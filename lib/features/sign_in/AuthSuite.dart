import 'package:firebase_auth/firebase_auth.dart';
import 'package:qwallet/features/sign_in/GoogleAuth.dart';
import 'package:rxdart/rxdart.dart';

class AuthSuite {
  static final instance = AuthSuite._();

  final _firebaseAuth = FirebaseAuth.instance;
  final _googleAuth = GoogleAuth.instance;

  late final BehaviorSubject<bool> _isSignInSubject;

  AuthSuite._() {
    _isSignInSubject = BehaviorSubject(
      onListen: () => _refresh(),
    );
  }

  Stream<bool> isSignIn() {
    return _isSignInSubject.stream;
  }

  Future<Map<String, String>> getAuthHeaders() {
    return _googleAuth.getAuthHeaders();
  }

  Future<void> signInWithGoogle() async {
    final credential = await _googleAuth.signIn();
    _firebaseAuth.signInWithCredential(credential);
    _refresh();
  }

  Future<void> signOut() async {
    _googleAuth.signOut();
    _firebaseAuth.signOut();
    _refresh();
  }

  void _refresh() async {
    final isSignIn = await _googleAuth.isSignIn();
    _isSignInSubject.add(isSignIn);
  }
}
