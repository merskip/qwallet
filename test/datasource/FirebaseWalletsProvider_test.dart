import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwallet/datasource/Account.dart';
import 'package:qwallet/datasource/AccountProvider.dart';
import 'package:qwallet/datasource/firebase/FirebaseWalletsProvider.dart';

class AccountProviderMock implements AccountProvider {
  final Account account;

  AccountProviderMock(this.account);

  @override
  Future<Account> getAccount() async => account;

  factory AccountProviderMock.empty() => AccountProviderMock(Account(
        firebaseUser: null,
      ));

  factory AccountProviderMock.firebaseUser({required String uid}) =>
      AccountProviderMock(Account(
        firebaseUser: MockUser(uid: uid),
      ));
}

void main() {
  late FirebaseFirestore firestore;

  setUp(() {
    firestore = MockFirestoreInstance();
  });

  test("When firebase user is null should emit nothing", () {
    final provider = FirebaseWalletsProvider(
      accountProvider: AccountProviderMock.empty(),
      firestore: firestore,
    );

    expect(
      provider.getWallets(),
      emitsDone,
    );
  });

  test("When are two wallets should emit only owned wallet ", () {
    final provider = FirebaseWalletsProvider(
      accountProvider: AccountProviderMock.firebaseUser(uid: "1234"),
      firestore: firestore,
    );
    firestore.collection("wallets").add({
      "ownersUid": ["1234"],
      "name": "Some name 1",
      "currency": "USD",
    });
    firestore.collection("wallets").add({
      "ownersUid": ["4321"],
      "name": "Some name 2",
      "currency": "USD",
    });

    provider.getWallets().listen(expectAsync1((wallets) {
      expect(wallets.length, 1);
      expect(wallets.first.name, "Some name 1");
      expect(wallets.first.currency.code, "USD");
    }));
  });

  test("When aren't owned wallets should emit nothing ", () {
    final provider = FirebaseWalletsProvider(
      accountProvider: AccountProviderMock.firebaseUser(uid: "1234"),
      firestore: firestore,
    );
    firestore.collection("wallets").add({
      "ownersUid": ["4321"],
      "name": "Some name 1",
      "currency": "USD",
    });
    firestore.collection("wallets").add({
      "ownersUid": ["4321"],
      "name": "Some name 2",
      "currency": "USD",
    });

    provider.getWallets().listen(expectAsync1((wallets) {
      expect(wallets.isEmpty, true);
    }));
  });
}
