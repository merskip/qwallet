import 'package:googleapis/sheets/v4.dart';
import 'package:intl/intl.dart';

import '../../utils/IterableFinding.dart';
import '../AccountProvider.dart';
import 'GoogleSpreadsheetWallet.dart';
import 'SheetsApiProvider.dart';

class GoogleSpreadsheetRepository extends SheetsApiProvider {
  GoogleSpreadsheetRepository({
    required AccountProvider accountProvider,
  }) : super(accountProvider: accountProvider);

  Future<GoogleSpreadsheetWallet> getWalletBySpreadsheetId(
    String spreadsheetId,
  ) async {
    final sheetsApi = await this.sheetsApi;
    final spreadsheet =
        await sheetsApi.spreadsheets.get(spreadsheetId, includeGridData: true);

    final generalSheet = spreadsheet.findSheetByTitle("Ogólne")!;
    final dailyBalanceSheet = spreadsheet.findSheetByTitle("Balans dzienny")!;
    final statisticsSheet = spreadsheet.findSheetByTitle("Statystyka")!;

    final incomes = _getIncomes(generalSheet);
    final transfers = _getTransfers(dailyBalanceSheet);
    final categories = _getCategories(statisticsSheet);
    final shops = _getShops(statisticsSheet);
    final statistics = _getStatistics(statisticsSheet);

    return GoogleSpreadsheetWallet(
      name: spreadsheet.properties?.title ?? "",
      incomes: incomes,
      transfers: transfers,
      lastTransferRowIndex: transfers.lastOrNull?.row,
      firstDate: _getFirstDate(statisticsSheet)!,
      lastDate: _getLastDate(statisticsSheet)!,
      categories: categories,
      shops: shops,
      statistics: statistics,
      generalSheet: generalSheet,
      dailyBalanceSheet: dailyBalanceSheet,
      statisticsSheet: statisticsSheet,
    );
  }

  List<double> _getIncomes(Sheet generalSheet) {
    return generalSheet.mapRow((_, row) => row.getDouble(column: 1));
  }

  List<GoogleSpreadsheetTransfer> _getTransfers(Sheet dailyBalanceSheet) {
    return dailyBalanceSheet.mapRow((index, row) {
      final date = row.getDate(column: 0);
      final type = row.getTransaferType(column: 1);
      final amount = row.getDouble(column: 2);
      final categorySymbol = row.getString(column: 3);
      if (date == null ||
          type == null ||
          amount == null ||
          categorySymbol == null) return null;

      return GoogleSpreadsheetTransfer(
        row: index,
        date: date,
        type: type,
        amount: amount,
        categorySymbol: categorySymbol,
        isForeignCapital: row.getString(column: 4) == "Kapitał obcy",
        shop: row.getString(column: 5),
        description: row.getString(column: 6),
      );
    });
  }

  DateTime? _getFirstDate(Sheet statisticsSheet) {
    return statisticsSheet.getRow(2)?.getDate(column: 8);
  }

  DateTime? _getLastDate(Sheet statisticsSheet) {
    final numbersOfRows = statisticsSheet.getNumbersOfRows();
    final reversedRows =
        List<int>.generate(numbersOfRows, (i) => numbersOfRows - i - 1);
    for (final row in reversedRows) {
      final date = statisticsSheet.getRow(row)?.getDate(column: 8);
      if (date != null) return date;
    }
    return null;
  }

  List<GoogleSpreadsheetCategory> _getCategories(Sheet statisticsSheet) {
    return statisticsSheet.mapRow((index, row) {
      final symbol = row.getString(column: 3);
      final totalExpenses = row.getDouble(column: 4);
      final description = row.getString(column: 5);
      if (symbol == null || description == null) return null;
      return GoogleSpreadsheetCategory(
        row: index,
        symbol: symbol,
        totalExpenses: totalExpenses ?? 0,
        description: description,
      );
    });
  }

  List<String> _getShops(Sheet statisticsSheet) {
    return statisticsSheet.mapRow((index, row) => row.getString(column: 16));
  }

  GoogleSpreadsheetStatistics _getStatistics(Sheet statisticsSheet) {
    return GoogleSpreadsheetStatistics(
      earnedIncome: statisticsSheet.getRow(0)!.getDouble(column: 1)!,
      gainedIncome: statisticsSheet.getRow(1)!.getDouble(column: 1)!,
      currentExpenses: statisticsSheet.getRow(3)!.getDouble(column: 1)!,
      constantExpenses: statisticsSheet.getRow(4)!.getDouble(column: 1)!,
      depreciateExpenses: statisticsSheet.getRow(5)!.getDouble(column: 1)!,
      totalExpenses: statisticsSheet.getRow(6)!.getDouble(column: 1)!,
      remainingAmount: statisticsSheet.getRow(7)!.getDouble(column: 1)!,
      balance: statisticsSheet.getRow(8)!.getDouble(column: 1)!,
      foreignCapital: statisticsSheet.getRow(9)!.getDouble(column: 1)!,
      averageBalanceFromConstantIncomes:
          statisticsSheet.getRow(11)?.getDouble(column: 1),
      averageBalance: statisticsSheet.getRow(12)?.getDouble(column: 1),
      predictedBalanceWithEarnedIncomes:
          statisticsSheet.getRow(14)?.getDouble(column: 1),
      predictedBalanceWithGainedIncomes:
          statisticsSheet.getRow(15)?.getDouble(column: 1),
      predictedBalance: statisticsSheet.getRow(16)?.getDouble(column: 1),
      availableDailyBudget: statisticsSheet.getRow(17)?.getDouble(column: 1),
    );
  }

  Future<void> updateTransactionCategory({
    required String spreadsheetId,
    required int transferRow,
    required DateTime date,
    required GoogleSpreadsheetTransferType type,
    required double amount,
    required String categorySymbol,
    required bool isForeignCapital,
    required String? shop,
    required String? description,
  }) async {
    final sheetsApi = await this.sheetsApi;
    final format = DateFormat("yyyy-MM-dd");
    final request = ValueRange()
      ..values = [
        [
          format.format(date),
          type.toText(),
          amount,
          categorySymbol,
          isForeignCapital ? "Kapitał obcy" : "",
          shop ?? "",
          description ?? "",
        ]
      ];
    final range = "'Balans Dzienny'!${transferRow + 1}:${transferRow + 1}";
    await sheetsApi.spreadsheets.values.update(
      request,
      spreadsheetId,
      range,
      valueInputOption: "USER_ENTERED",
    );
  }

  Future<void> removeTransaction({
    required String spreadsheetId,
    required int sheetId,
    required int transferRow,
  }) async {
    final sheetsApi = await this.sheetsApi;
    final request = BatchUpdateSpreadsheetRequest();
    request.requests = [
      Request()
        ..deleteDimension = (DeleteDimensionRequest()
          ..range = (DimensionRange()
            ..sheetId = sheetId
            ..dimension = "ROWS"
            ..startIndex = transferRow
            ..endIndex = transferRow + 1))
    ];
    await sheetsApi.spreadsheets.batchUpdate(request, spreadsheetId);
  }
}

extension _SpreadsheetFinding on Spreadsheet {
  Sheet? findSheetByTitle(String title) {
    return sheets?.findFirstOrNull((sheet) => sheet.properties?.title == title);
  }
}

extension _SheetIterator on Sheet {
  int getNumbersOfRows() => data?[0].rowData?.length ?? 0;

  RowData? getRow(int index) {
    return data?[0].rowData?[index];
  }

  List<T> mapRow<T>(T? Function(int index, RowData row) callback) {
    final rows = data?[0].rowData;
    final list = <T>[];
    var index = 0;
    rows?.forEach((cell) {
      final element = callback(index, cell);
      if (element != null) list.add(element);
      index++;
    });
    return list;
  }
}

extension _RowDataConverting on RowData {
  double? getDouble({required int column}) {
    return values?[column].effectiveValue?.numberValue;
  }

  String? getString({required int column}) {
    final string = values?[column].effectiveValue?.stringValue;
    return string != null && string.isNotEmpty ? string : null;
  }

  DateTime? getDate({required int column}) {
    final string = values?[column].formattedValue;
    if (string == null) return null;
    return DateTime.tryParse(string);
  }

  GoogleSpreadsheetTransferType? getTransaferType({required int column}) {
    final string = values?[column].effectiveValue?.stringValue;
    if (string == "Bieżące")
      return GoogleSpreadsheetTransferType.current;
    else if (string == "Stałe")
      return GoogleSpreadsheetTransferType.constant;
    else if (string == "Amortyzowane")
      return GoogleSpreadsheetTransferType.depreciate;
    else
      return null;
  }
}
