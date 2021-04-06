import 'package:qwallet/data_source/Identifier.dart';

import '../Currency.dart';
import 'firebase/PrivateLoan.dart';

abstract class PrivateLoansProvider {
  Stream<List<PrivateLoan>> getPrivateLoans({
    bool includeFullyRepaid = false,
  });

  Stream<PrivateLoan> getPrivateLoan(String id);

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
  });

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
  });

  Future<void> updatePrivateLoanRepaidAmount({
    required Identifier<PrivateLoan> loanId,
    required double amount,
    required double repaidAmount,
  });

  Future<void> updateRepaidAmountsForPrivateLoans({
    required List<PrivateLoan> privateLoans,
    required double getRepaidAmount(PrivateLoan loan),
  });

  Future<void> removePrivateLoan({
    required Identifier<PrivateLoan> loanId,
  });
}
