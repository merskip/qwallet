import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/features/sign_in/AuthSuite.dart';
import 'package:rxdart/rxdart.dart';

import '../RemoteUserPreferences.dart';
import '../RemoteUserPreferencesProvider.dart';
import 'FirebaseConverting.dart';

class FirebaseRemoteUserPreferencesProvider
    implements RemoteUserPreferencesProvider {
  final AuthSuite authSuite;
  final FirebaseFirestore firestore;

  FirebaseRemoteUserPreferencesProvider({
    required this.authSuite,
    required this.firestore,
  });

  @override
  Stream<RemoteUserPreferences> getUserPreferences() {
    return authSuite.getLastAccount().flatMap((account) {
      return firestore
          .collection("usersPreferences")
          .doc(account.uid)
          .snapshots()
          .map((snapshot) => RemoteUserPreferences(
                isGoogleSheetsWalletEnabled:
                    snapshot.getBool("isGoogleSheetsWalletEnabled") ?? false,
              ));
    });
  }
}
