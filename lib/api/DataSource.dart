import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as CloudFirestore;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/model/user.dart';
import 'package:rxdart/rxdart.dart';

import '../Currency.dart';
import 'Model.dart';

@deprecated
class DataSource {
  static final DataSource instance = DataSource._privateConstructor();

  final firestore = CloudFirestore.FirebaseFirestore.instance;
  late User? currentUser;

  List<User>? _cachedUsers;

  DataSource._privateConstructor();
}

extension PrivateLoansDataSource on DataSource {
  Stream<List<PrivateLoan>> getPrivateLoans({
    bool includeFullyRepaid = false,
  }) {
    final getSnapshots =
        (CloudFirestore.Query filter(CloudFirestore.Query query)) {
      CloudFirestore.Query query = firestore.collection("privateLoans");
      query = filter(query);

      if (!includeFullyRepaid)
        query = query.where("isFullyRepaid", isEqualTo: false);

      return query.snapshots();
    };

    return CombineLatestStream.combine3(
      getSnapshots((q) => q.where("lenderUid", isEqualTo: currentUser!.uid)),
      getSnapshots((q) => q.where("borrowerUid", isEqualTo: currentUser!.uid)),
      getUsers().asStream(),
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
  }

  Stream<PrivateLoan> getPrivateLoan(String id) {
    final loanSnapshots =
        firestore.collection("privateLoans").doc(id).snapshots();

    return CombineLatestStream.combine2(
      loanSnapshots,
      getUsers().asStream(),
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
    required FirebaseReference<PrivateLoan> loanRef,
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
    return loanRef.documentReference.update({
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
    required FirebaseReference<PrivateLoan> loanRef,
    required double amount,
    required double repaidAmount,
  }) {
    return loanRef.documentReference.update({
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
    required FirebaseReference<PrivateLoan> loanRef,
  }) {
    return loanRef.documentReference.delete();
  }
}

extension UsersDataSource on DataSource {
  Future<List<User>> getUsers() async {
    final cachedUsers = _cachedUsers;
    if (cachedUsers != null) return cachedUsers;
    final users = await _fetchUsers();
    _cachedUsers = users;
    return users;
  }

  Future<List<User>> _fetchUsers() async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable("getUsers");
    dynamic response = await callable.call();
    final content = response.data as List;

    return content
        .map((item) => User.fromJson(item.cast<String, dynamic>()))
        .where((user) => !user.isAnonymous)
        .toList();
  }

  Future<User> getUserByUid(String userUid) async {
    final users = await getUsers();
    return users.firstWhere((user) => user.uid == userUid);
  }

  Future<List<User>> getUsersByUids(List<String> usersUids) async {
    final users = await getUsers();
    return usersUids
        .map((uid) => users.firstWhere(
              (user) => user.uid == uid,
              orElse: () => User.emptyFromUid(uid),
            ))
        .toList();
  }
}

extension DateTimeUtils on DateTime {
  CloudFirestore.Timestamp toTimestamp() =>
      CloudFirestore.Timestamp.fromDate(this);
}
