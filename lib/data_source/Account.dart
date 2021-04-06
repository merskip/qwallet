import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:google_sign_in/google_sign_in.dart';

class Account {
  final FirebaseAuth.User? firebaseUser;
  final GoogleSignInAccount? googleAccount;

  Account({this.firebaseUser, this.googleAccount});
}
