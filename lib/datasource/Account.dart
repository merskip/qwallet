import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class Account {
  final FirebaseAuth.User? firebaseUser;

  Account({this.firebaseUser});
}
