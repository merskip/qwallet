import 'package:qwallet/datasource/googlesheets/SheetsApiProvider.dart';

import '../AccountProvider.dart';
import 'GoogleSpreadsheetWallet.dart';

class GoogleSpreadsheetRepository extends SheetsApiProvider {
  GoogleSpreadsheetRepository({
    required AccountProvider accountProvider,
  }) : super(accountProvider: accountProvider);

  Future<GoogleSpreadsheetWallet> getWalletBySpreadsheetId(
    String spreadsheetId,
  ) {
    throw UnsupportedError("Not implemented yet");
  }
}
