import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/data_source/CategoriesProvider.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';

import '../../IconsSerialization.dart';
import '../../utils.dart';
import 'CloudFirestoreUtils.dart';
import 'FirebaseCategory.dart';

class FirebaseCategoriesProvider implements CategoriesProvider {
  final FirebaseFirestore firestore;

  FirebaseCategoriesProvider({
    required this.firestore,
  });

  @override
  Stream<List<Category>> getCategories(Identifier<Wallet> walletId) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("categories")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((s) => FirebaseCategory(s)).toList()
            ..sort((lhs, rhs) => lhs.compareTo(rhs)),
        );
  }

  @override
  Stream<Category> getCategoryByIdentifier(
      Identifier<Wallet> walletId, Identifier<Category> categoryId) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("categories")
        .doc(categoryId.id)
        .snapshots()
        .filterNotExists()
        .map((s) => FirebaseCategory(s));
  }

  Future<void> updateCategoriesOrder({
    required Identifier<Wallet> walletId,
    required List<Identifier<Category>> categoriesOrder,
  }) async {
    assert(walletId.domain == "firebase");
    await firestore.runTransaction((transaction) async {
      categoriesOrder.forEach((category) {
        final categoryReference = firestore
            .collection("wallets")
            .doc(walletId.id)
            .collection("categories")
            .doc(category.id);

        transaction.update(categoryReference, {
          'order': categoriesOrder.indexOf(category),
        });
      });
    });
  }

  Future<void> addCategory({
    required Identifier<Wallet> walletId,
    required String title,
    required Color primaryColor,
    required Color backgroundColor,
    required IconData icon,
    required int order,
  }) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("categories")
        .add({
      "title": title,
      "primaryColor": primaryColor.toHex(),
      "backgroundColor": backgroundColor.toHex(),
      "icon": serializeIcon(icon),
      "order": order
    });
  }

  Future<void> updateCategory({
    required Identifier<Wallet> walletId,
    required Identifier<Category> categoryId,
    required String title,
    required Color primaryColor,
    required Color backgroundColor,
    required IconData icon,
    required int order,
  }) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("categories")
        .doc(categoryId.id)
        .update({
      "title": title,
      "primaryColor": primaryColor.toHex(),
      "backgroundColor": backgroundColor.toHex(),
      "icon": serializeIcon(icon),
      "order": order
    });
  }

  Future<void> removeCategory({
    required Identifier<Wallet> walletId,
    required Identifier<Category> categoryId,
  }) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("categories")
        .doc(categoryId.id)
        .delete();
  }
}
