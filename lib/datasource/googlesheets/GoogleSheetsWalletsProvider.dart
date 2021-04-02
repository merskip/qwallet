import 'dart:async';

import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';

import '../../Money.dart';
import '../../utils/IterableFinding.dart';
import '../AccountProvider.dart';
import '../CategoriesProvider.dart';
import '../WalletsProvider.dart';
import 'GoogleAuthClient.dart';
import 'GoogleSheetsWallet.dart';

class GoogleSheetsWalletsProvider implements WalletsProvider {
  final AccountProvider accountProvider;
  final CategoriesProvider categoriesProvider;
  final List<Identifier<Wallet>> walletsIds;

  GoogleSheetsWalletsProvider({
    required this.accountProvider,
    required this.categoriesProvider,
    required this.walletsIds,
  });

  @override
  Stream<List<Wallet>> getWallets() {
    return Future(() async {
      final wallets = <Wallet>[];
      for (final walletId in walletsIds) {
        final wallet = await _getWalletByIdentifier(walletId);
        if (wallet != null) wallets.add(wallet);
      }
      return wallets;
    }).asStream();
  }

  @override
  Stream<Wallet?> getWalletByIdentifier(Identifier<Wallet> walletId) {
    return _getWalletByIdentifier(walletId).asStream();
  }

  Future<Wallet?> _getWalletByIdentifier(Identifier<Wallet> walletId) {
    return onSheetsApi((sheetsApi) async {
      final spreadsheet = await sheetsApi.spreadsheets.get(walletId.id);

      final statisticsSheetMetadata = spreadsheet.sheets
          ?.findFirstOrNull((sheet) => sheet.properties?.title == "Statystyka");

      final request = GetSpreadsheetByDataFilterRequest();
      final dataFilter = DataFilter();
      final gridRange = GridRange();
      gridRange.sheetId = statisticsSheetMetadata!.properties!.sheetId;
      gridRange.startColumnIndex = 0;
      gridRange.endColumnIndex = 2;
      dataFilter.gridRange = gridRange;
      request.dataFilters = [dataFilter];
      request.includeGridData = true;
      final statisticsSheet =
          await sheetsApi.spreadsheets.getByDataFilter(request, walletId.id);

      final earned = statisticsSheet.sheets![0].data![0].rowData![0].values![1]
          .effectiveValue!.numberValue!;
      final looted = statisticsSheet.sheets![0].data![0].rowData![1].values![1]
          .effectiveValue!.numberValue!;

      final totalExpenses = statisticsSheet.sheets![0].data![0].rowData![6]
          .values![1].effectiveValue!.numberValue!;

      return GoogleSheetsWallet(
        identifier: walletId,
        name: spreadsheet.properties!.title!,
        currency: Currency.fromCode("PLN"),
        totalExpense: Money(totalExpenses, Currency.fromCode("PLN")),
        totalIncome: Money(earned + looted, Currency.fromCode("PLN")),
        categories: await categoriesProvider.getCategories(walletId).first,
      );
    });
  }

  Future<T?> onSheetsApi<T>(
      FutureOr<T> Function(SheetsApi sheetsApi) callback) async {
    final account = await accountProvider.getAccount();
    if (account.googleAccount == null) return Future.value(null);
    final client = GoogleAuthClient(account.googleAccount!);
    final sheetsApi = SheetsApi(client);
    return callback(sheetsApi);
  }
}
