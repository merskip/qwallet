import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/datasource/CategoriesProvider.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsCategory.dart';
import 'package:qwallet/utils/IterableFinding.dart';

class GoogleSheetsCategoriesProvider extends CategoriesProvider {
  final SheetsApi sheetsApi;

  GoogleSheetsCategoriesProvider(this.sheetsApi);

  @override
  Stream<List<Category>> getCategories(Identifier<Wallet> walletId) {
    assert(walletId.domain == "google_sheets");
    return sheetsApi.spreadsheets.get(walletId.id).then((spreadsheet) async {
      final statisticsSheetMetadata = spreadsheet.sheets
          ?.findFirstOrNull((sheet) => sheet.properties?.title == "Statystyka");

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
    }).asStream();
  }

  List<GoogleSheetsCategory> _parseCategories(Sheet statisticsSheet) {
    final categories = <GoogleSheetsCategory>[];

    int order = 0;
    for (final row in statisticsSheet.data![0].rowData!) {
      final symbol = row.values![0].formattedValue;
      final title = row.values![2].formattedValue;
      if (symbol == null) break;

      final identifier =
          Identifier<Category>(domain: "google_sheet", id: "${order + 1}");

      categories.add(GoogleSheetsCategory(
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
}
