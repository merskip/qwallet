import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwallet/data_source/Account.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/WalletsProvider.dart';
import 'package:qwallet/data_source/firebase/CloudFirestoreUtils.dart';
import 'package:qwallet/data_source/firebase/FirebaseCategoriesProvider.dart';
import 'package:qwallet/data_source/firebase/FirebaseWalletsProvider.dart';

import '../utils.dart';
import 'AccountProviderMock.dart';

WalletsProvider makeWalletsProvider(
  FirebaseFirestore firestore, {
  String? firebaseUserId,
}) {
  final firebaseUser =
      firebaseUserId != null ? MockUser(uid: firebaseUserId) : null;
  final categoriesProvider = FirebaseCategoriesProvider(
    firestore: firestore,
  );
  return FirebaseWalletsProvider(
    accountProvider: AccountProviderMock(Account(
      firebaseUser: firebaseUser,
    )),
    categoriesProvider: categoriesProvider,
    firestore: firestore,
  );
}

void main() {
  late FirebaseFirestore firestore;

  setUp(() {
    firestore = MockFirestoreInstance();
  });

  test("When firebase user is null should emit nothing", () {
    final walletsProvider = makeWalletsProvider(firestore);

    expect(
      walletsProvider.getWallets(),
      emitsDone,
    );
  });

  test("When are two wallets should emit only owned wallet ", () {
    final walletsProvider = makeWalletsProvider(
      firestore,
      firebaseUserId: "1234",
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

    walletsProvider.getWallets().listen(expectAsync1((wallets) {
      expect(wallets.length, 1);
      expect(wallets[0].name, "Some name 1");
      expect(wallets[0].currency.code, "USD");
    }));
  });

  test("When aren't owned wallets should emit nothing ", () {
    final walletsProvider = makeWalletsProvider(
      firestore,
      firebaseUserId: "1234",
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

    walletsProvider.getWallets().listen(expectAsync1((wallets) {
      expect(wallets.isEmpty, true);
    }));
  });

  test("When wallet is updating should emit new wallet ", () async {
    final walletsProvider = makeWalletsProvider(
      firestore,
      firebaseUserId: "1234",
    );

    final wallets = walletsProvider.getWallets();

    final wallet = await firestore.collection("wallets").add({
      "ownersUid": ["1234"],
      "name": "Some name 1",
      "currency": "USD",
    });

    Future.delayed(Duration(milliseconds: 10)).then((_) {
      wallet.update({"name": "Some other name 1"});
    });

    expect(
      wallets,
      emitsInOrder([
        expectNext((List<Wallet> wallets) {
          expect(wallets.length, 1);
          expect(wallets[0].name, "Some name 1");
          expect(wallets[0].currency.code, "USD");
        }),
        expectNext((List<Wallet> wallets) {
          expect(wallets.length, 1);
          expect(wallets[0].name, "Some other name 1");
          expect(wallets[0].currency.code, "USD");
        }),
      ]),
    );
  });

  test("When request single wallet should emit this wallet", () async {
    final walletsProvider = makeWalletsProvider(
      firestore,
      firebaseUserId: "1234",
    );

    final walletReference = await firestore.collection("wallets").add({
      "ownersUid": ["1234"],
      "name": "Some name 1",
      "currency": "USD",
    });

    final wallet =
        walletsProvider.getWalletByIdentifier(walletReference.toIdentifier());

    expect(
      wallet,
      emitsInOrder([
        expectNext((Wallet wallet) {
          expect(wallet.name, "Some name 1");
          expect(wallet.currency.code, "USD");
        }),
      ]),
    );
  });
}
