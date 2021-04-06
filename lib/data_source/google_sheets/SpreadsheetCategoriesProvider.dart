import 'dart:async';

import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/data_source/CategoriesProvider.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/utils/IterableFinding.dart';

import '../AccountProvider.dart';
import 'GoogleAuthClient.dart';
import 'SpreadsheetCategory.dart';

class SpreadsheetCategoriesProvider extends CategoriesProvider {
  final AccountProvider accountProvider;

  SpreadsheetCategoriesProvider({
    required this.accountProvider,
  });

  @override
  Stream<List<Category>> getCategories(Identifier<Wallet> walletId) {
    assert(walletId.domain == "google_sheets");
    return onSheetsApi((sheetsApi) async {
      return sheetsApi.spreadsheets.get(walletId.id).then((spreadsheet) async {
        final statisticsSheetMetadata = spreadsheet.sheets?.findFirstOrNull(
            (sheet) => sheet.properties?.title == "Statystyka");

        final request = GetSpreadsheetByDataFilterRequest();
        final dataFilter = DataFilter();
        final gridRange = GridRange();
        gridRange.sheetId = statisticsSheetMetadata!.properties!.sheetId;
        gridRange.startColumnIndex = 3;
        gridRange.endColumnIndex = 6;
        dataFilter.gridRange = gridRange;
        request.dataFilters = [dataFilter];
        request.includeGridData = true;
        final result =
            await sheetsApi.spreadsheets.getByDataFilter(request, walletId.id);

        return _parseCategories(result.sheets![0]);
      }).catchError((err) {
        print(err);
      });
    }).asStream();
  }

  List<SpreadsheetCategory> _parseCategories(Sheet statisticsSheet) {
    final categories = <SpreadsheetCategory>[];

    int order = 0;
    for (final row in statisticsSheet.data![0].rowData!) {
      final symbol = row.values![0].formattedValue;
      final title = row.values![2].formattedValue;
      if (symbol == null) break;

      final identifier =
          Identifier<Category>(domain: "google_sheet", id: "${order + 1}");

      categories.add(SpreadsheetCategory(
        identifier: identifier,
        title: title!,
        symbol: symbol,
        primaryColor: null,
        backgroundColor: null,
        order: order,
      ));
      order++;
    }
    return categories;
  }

  Future<T> onSheetsApi<T>(
      FutureOr<T> Function(SheetsApi sheetsApi) callback) async {
    final account = await accountProvider.getAccount().first;
    final client = GoogleAuthClient(account.googleAccount!);
    final sheetsApi = SheetsApi(client);
    return callback(sheetsApi);
  }
}
