import 'package:cloud_firestore/cloud_firestore.dart' as CloudFirestore;
import 'package:qwallet/Currency.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/PrivateLoansProvider.dart';
import 'package:qwallet/datasource/UsersProvider.dart';
import 'package:qwallet/model/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

import '../../utils.dart';
import '../AccountProvider.dart';

class FirebasePrivateLoansProvider implements PrivateLoansProvider {
  final AccountProvider accountProvider;
  final UsersProvider usersProvider;
  final CloudFirestore.FirebaseFirestore firestore;

  FirebasePrivateLoansProvider({
    required this.accountProvider,
    required this.usersProvider,
    required this.firestore,
  });

  @override
  Stream<List<PrivateLoan>> getPrivateLoans({bool includeFullyRepaid = false}) {
    return onFirebaseUser((user) {
      final getSnapshots =
          (CloudFirestore.Query filter(CloudFirestore.Query query)) {
        CloudFirestore.Query query = firestore.collection("privateLoans");
        query = filter(query);

        if (!includeFullyRepaid)
          query = query.where("isFullyRepaid", isEqualTo: false);

        return query.snapshots();
      };

      return CombineLatestStream.combine3(
        getSnapshots((q) => q.where("lenderUid", isEqualTo: user.uid)),
        getSnapshots((q) => q.where("borrowerUid", isEqualTo: user.uid)),
        usersProvider.getUsers().asStream(),
        (
          CloudFirestore.QuerySnapshot loansAsLender,
          CloudFirestore.QuerySnapshot loansAsBorrower,
          List<User> users,
        ) {
          final documents = loansAsLender.docs + loansAsBorrower.docs;
          return (documents.map((d) => PrivateLoan(d, users)).toList()
                ..sort((lhs, rhs) => lhs.date.compareTo(rhs.date)))
              .reversed
              .toList();
        },
      );
    });
  }

  Stream<PrivateLoan> getPrivateLoan(String id) {
    final loanSnapshots =
        firestore.collection("privateLoans").doc(id).snapshots();

    return CombineLatestStream.combine2(
      loanSnapshots,
      usersProvider.getUsers().asStream(),
      (CloudFirestore.DocumentSnapshot snapshot, List<User> users) =>
          PrivateLoan(snapshot, users),
    );
  }

  Future<void> addPrivateLoan({
    required String? lenderUid,
    required String? lenderName,
    required String? borrowerUid,
    required String? borrowerName,
    required double amount,
    required double repaidAmount,
    required Currency currency,
    required String title,
    required DateTime date,
  }) {
    return firestore.collection("privateLoans").add({
      "lenderUid": lenderUid,
      "lenderName": lenderName,
      "borrowerUid": borrowerUid,
      "borrowerName": borrowerName,
      "amount": amount,
      "repaidAmount": repaidAmount,
      "currency": currency.code,
      "isFullyRepaid": repaidAmount >= amount,
      "title": title,
      "date": date.toTimestamp(),
    });
  }

  Future<void> updatePrivateLoan({
    required Identifier<PrivateLoan> loanId,
    required String? lenderUid,
    required String? lenderName,
    required String? borrowerUid,
    required String? borrowerName,
    required double amount,
    required double repaidAmount,
    required Currency currency,
    required String title,
    required DateTime date,
  }) {
    return firestore.collection("privateLoans").doc(loanId.id).update({
      "lenderUid": lenderUid,
      "lenderName": lenderName,
      "borrowerUid": borrowerUid,
      "borrowerName": borrowerName,
      "amount": amount,
      "repaidAmount": repaidAmount,
      "isFullyRepaid": repaidAmount >= amount,
      "currency": currency.code,
      "title": title,
      "date": date.toTimestamp(),
    });
  }

  Future<void> updatePrivateLoanRepaidAmount({
    required Identifier<PrivateLoan> loanId,
    required double amount,
    required double repaidAmount,
  }) {
    return firestore.collection("privateLoans").doc(loanId.id).update({
      "amount": amount,
      "repaidAmount": repaidAmount,
      "isFullyRepaid": repaidAmount >= amount,
    });
  }

  Future<void> updateRepaidAmountsForPrivateLoans({
    required List<PrivateLoan> privateLoans,
    required double getRepaidAmount(PrivateLoan loan),
  }) async {
    await firestore.runTransaction((transaction) async {
      for (final loan in privateLoans) {
        final repaidAmount = getRepaidAmount(loan);
        transaction.update(loan.reference.documentReference, {
          "repaidAmount": repaidAmount,
          "isFullyRepaid": repaidAmount >= loan.amount.amount,
        });
      }
    });
  }

  Future<void> removePrivateLoan({
    required Identifier<PrivateLoan> loanId,
  }) {
    return firestore.collection("privateLoans").doc(loanId.id).delete();
  }

  Stream<T> onFirebaseUser<T>(Stream<T> Function(FirebaseAuth.User user) callback) {
    return accountProvider.getAccount().asStream().flatMap((account) {
      final user = account.firebaseUser;
      if (user == null) return Stream.empty();

      return callback(user);
    });
  }
}
