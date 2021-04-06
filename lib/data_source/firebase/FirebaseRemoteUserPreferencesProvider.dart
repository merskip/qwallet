import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qwallet/data_source/AccountProvider.dart';
import 'package:rxdart/rxdart.dart';

import '../RemoteUserPreferences.dart';
import '../RemoteUserPreferencesProvider.dart';
import 'FirebaseConverting.dart';

class FirebaseRemoteUserPreferencesProvider
    implements RemoteUserPreferencesProvider {
  final AccountProvider accountProvider;
  final FirebaseFirestore firestore;

  FirebaseRemoteUserPreferencesProvider({
    required this.accountProvider,
    required this.firestore,
  });

  @override
  Stream<RemoteUserPreferences> getUserPreferences() {
    return onFirebaseUser((user) {
      return firestore
          .collection("usersPreferences")
          .doc(user.uid)
          .snapshots()
          .map((snapshot) => RemoteUserPreferences(
                isGoogleSheetsWalletEnabled:
                    snapshot.getBool("isGoogleSheetsWalletEnabled") ?? false,
              ));
    });
  }

  Stream<T> onFirebaseUser<T>(Stream<T> Function(User user) callback) {
    return accountProvider.getAccount().flatMap((account) {
      final user = account.firebaseUser;
      if (user == null) return Stream.error("account.firebaseUser is null");
      return callback(user);
    });
  }
}
