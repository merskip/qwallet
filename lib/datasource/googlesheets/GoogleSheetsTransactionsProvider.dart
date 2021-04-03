import 'dart:async';

import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Transaction.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsTransaction.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsWallet.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsWalletsProvider.dart';

import '../../utils/IterableFinding.dart';
import '../AccountProvider.dart';
import 'GoogleAuthClient.dart';

class GoogleSheetsTransactionsProvider implements TransactionsProvider {
  final AccountProvider accountProvider;
  final GoogleSheetsWalletsProvider walletsProvider;

  GoogleSheetsTransactionsProvider({
    required this.accountProvider,
    required this.walletsProvider,
  });

  @override
  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletId,
  }) {
    assert(walletId.domain == "google_sheets");
    return onSheetsApi((sheetsApi) async {
      return sheetsApi.spreadsheets.get(walletId.id).then((spreadsheet) async {
        final dailyBalanceSheetMetadata = spreadsheet.sheets?.findFirstOrNull(
            (sheet) => sheet.properties?.title == "Balans dzienny");

        final request = GetSpreadsheetByDataFilterRequest();
        final dataFilter = DataFilter();
        final gridRange = GridRange();
        gridRange.sheetId = dailyBalanceSheetMetadata!.properties!.sheetId;
        dataFilter.gridRange = gridRange;
        request.dataFilters = [dataFilter];
        request.includeGridData = true;
        final result =
            await sheetsApi.spreadsheets.getByDataFilter(request, walletId.id);
        final wallet =
            await walletsProvider.getWalletByIdentifier(walletId).first;
        final transactions = _parseTransactions(wallet!, result.sheets![0]);

        return LatestTransactions(wallet, transactions);
      }).catchError((err) {
        print(err);
      });
    }).asStream();
  }

  List<GoogleSheetsTransaction> _parseTransactions(
      GoogleSheetsWallet wallet, Sheet statisticsSheet) {
    final transactions = <GoogleSheetsTransaction>[];
    var column = 0;
    for (final row in statisticsSheet.data![0].rowData!) {
      if (row.values![0].formattedValue == null) break;
      final date = DateTime.parse(row.values![0].formattedValue!);
      final amount = row.values![2].effectiveValue!.numberValue!;
      final categorySymbol = row.values![3].effectiveValue!.stringValue;
      final title = row.values![6].effectiveValue!.stringValue;
      transactions.add(GoogleSheetsTransaction(
        identifier: Identifier(domain: "google_sheets", id: column.toString()),
        type: amount < 0 ? TransactionType.expense : TransactionType.income,
        amount: amount.abs(),
        title: title,
        date: date,
        category: wallet.categories
            .findFirstOrNull((c) => c.symbol == categorySymbol),
      ));
      column++;
    }
    return transactions;
  }

  Future<T> onSheetsApi<T>(
      FutureOr<T> Function(SheetsApi sheetsApi) callback) async {
    final account = await accountProvider.getAccount();
    final client = GoogleAuthClient(account.googleAccount!);
    final sheetsApi = SheetsApi(client);
    return callback(sheetsApi);
  }
}
