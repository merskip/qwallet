import 'package:googleapis/sheets/v4.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/logger.dart';

import '../../utils/IterableFinding.dart';
import '../AccountProvider.dart';
import 'GoogleSpreadsheetWallet.dart';
import 'SheetsApiProvider.dart';

class GoogleSpreadsheetRepository extends GoogleApiProvider {
  GoogleSpreadsheetRepository({
    required AccountProvider accountProvider,
  }) : super(accountProvider);

  Future<GoogleSpreadsheetWallet> getWalletBySpreadsheetId(
    String spreadsheetId,
  ) async {
    logger.debug("getWalletBySpreadsheetId id=$spreadsheetId");
    final sheetsApi = await this.sheetsApi;
    final spreadsheet = await sheetsApi.spreadsheets.get(
      spreadsheetId,
      $fields: "spreadsheetId,"
          "spreadsheetUrl,"
          "properties(title),"
          "sheets("
          "properties(sheetId,title),"
          "data("
          "rowData(values(effectiveValue)),"
          "rowMetadata(developerMetadata(metadataKey,metadataValue))"
          ")"
          ")",
      includeGridData: true,
    );

    final generalSheet = spreadsheet.findSheetByTitle("Ogólne")!;
    final dailyBalanceSheet = spreadsheet.findSheetByTitle("Balans dzienny")!;
    final statisticsSheet = spreadsheet.findSheetByTitle("Statystyka")!;
    logger.verbose("Found sheets");

    final incomes = _getIncomes(generalSheet);
    logger.verbose("Parsed incomes (${incomes.length})");

    final transfers = _getTransfers(dailyBalanceSheet);
    logger.verbose("Parsed transfers (${transfers.length})");

    final categories = _getCategories(statisticsSheet);
    logger.verbose("Parsed categories (${categories.length})");

    final shops = _getShops(statisticsSheet);
    logger.verbose("Parsed shops (${shops.length})");

    final statistics = _getStatistics(statisticsSheet);
    logger.verbose("Parsed statistics");

    return GoogleSpreadsheetWallet(
      name: spreadsheet.properties?.title ?? "",
      incomes: incomes,
      transfers: transfers,
      firstDate: _getFirstDate(statisticsSheet)!,
      lastDate: _getLastDate(statisticsSheet)!,
      categories: categories,
      shops: shops,
      statistics: statistics,
      spreadsheet: spreadsheet,
      generalSheet: generalSheet,
      dailyBalanceSheet: dailyBalanceSheet,
      statisticsSheet: statisticsSheet,
    );
  }

  List<double> _getIncomes(Sheet generalSheet) {
    throw Exception("Test");
    return generalSheet.mapRow((_, row) => row.getDouble(column: 1));
  }

  List<GoogleSpreadsheetTransaction> _getTransfers(Sheet dailyBalanceSheet) {
    return dailyBalanceSheet.mapRow((index, row) {
      final date = row.getDate(column: 0);
      final type = row.getTransactionType(column: 1);
      final amount = row.getDouble(column: 2);
      final categorySymbol = row.getString(column: 3);
      if (date == null ||
          type == null ||
          amount == null ||
          categorySymbol == null) return null;

      return GoogleSpreadsheetTransaction(
        row: index,
        date: date,
        type: type,
        amount: amount,
        categorySymbol: categorySymbol,
        isForeignCapital: row.getString(column: 4) == "Kapitał obcy",
        shop: row.getString(column: 5),
        description: row.getString(column: 6),
        attachedFiles:
            dailyBalanceSheet.getMetadataForRow(index, "attachedFile"),
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
    return statisticsSheet.mapRow(
      (index, row) => row.hasColumn(16) ? row.getString(column: 16) : null,
    );
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

  Future<int> addTransaction({
    required String spreadsheetId,
    required DateTime date,
    required GoogleSpreadsheetTransactionType? type,
    required double amount,
    required String? categorySymbol,
    required bool isForeignCapital,
    required String? shop,
    required String? description,
  }) async {
    logger.debug("Adding transaction id=$spreadsheetId");
    final sheetsApi = await this.sheetsApi;
    final format = DateFormat("yyyy-MM-dd");
    final request = ValueRange()
      ..values = [
        [
          format.format(date),
          type?.toText() ?? "",
          amount,
          categorySymbol ?? "",
          isForeignCapital ? "Kapitał obcy" : "",
          shop ?? "",
          description ?? "",
        ]
      ];
    final range = "'Balans Dzienny'!A1:A";
    final response = await sheetsApi.spreadsheets.values.append(
      request,
      spreadsheetId,
      range,
      valueInputOption: "USER_ENTERED",
    );
    logger.verbose("Added transaction: "
        "tableRange=${response.tableRange}, "
        "updatedRange=${response.updates?.updatedRange}");

    final updatedRange = response.updates?.updatedRange;
    final firstCell = updatedRange?.split('!')[1].split(':')[0];
    if (firstCell != null) {
      final firstMatch = RegExp("[A-Z]+([0-9]+)").firstMatch(firstCell);
      final row = firstMatch?.group(1);
      if (row != null) {
        final rowIndex = int.parse(row) - 1;
        logger.verbose("   ...rowIndex=$rowIndex");
        return rowIndex;
      }
    }
    return Future.error("Failed appending row");
  }

  Future<void> updateTransaction({
    required String spreadsheetId,
    required int transferRow,
    required DateTime date,
    required GoogleSpreadsheetTransactionType type,
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

  Future<void> addAttachedFile({
    required GoogleSpreadsheetWallet wallet,
    required int rowIndex,
    required Uri attachedFile,
  }) async {
    final request = BatchUpdateSpreadsheetRequest();
    request.requests = [
      Request()
        ..createDeveloperMetadata = (CreateDeveloperMetadataRequest()
          ..developerMetadata = (DeveloperMetadata()
            ..location = (DeveloperMetadataLocation()
              ..dimensionRange = (DimensionRange()
                ..dimension = "ROWS"
                ..sheetId = wallet.dailyBalanceSheet.properties!.sheetId!
                ..startIndex = rowIndex
                ..endIndex = rowIndex + 1))
            ..metadataKey = "attachedFile"
            ..metadataValue = attachedFile.toString()
            ..visibility = "DOCUMENT")),
    ];
    await (await this.sheetsApi).spreadsheets.batchUpdate(
          request,
          wallet.spreadsheet.spreadsheetId!,
        );
  }

  Future<void> removeAttachedFile({
    required GoogleSpreadsheetWallet wallet,
    required int rowIndex,
    required Uri attachedFile,
  }) async {
    final request = BatchUpdateSpreadsheetRequest();
    request.requests = [
      Request()
        ..deleteDeveloperMetadata = (DeleteDeveloperMetadataRequest()
          ..dataFilter = (DataFilter()
            ..developerMetadataLookup = (DeveloperMetadataLookup()
              ..metadataLocation = (DeveloperMetadataLocation()
                ..dimensionRange = (DimensionRange()
                  ..dimension = "ROWS"
                  ..sheetId = wallet.dailyBalanceSheet.properties!.sheetId!
                  ..startIndex = rowIndex
                  ..endIndex = rowIndex + 1))
              ..metadataKey = "attachedFile"
              ..metadataValue = attachedFile.toString()
              ..visibility = "DOCUMENT"))),
    ];
    await (await this.sheetsApi).spreadsheets.batchUpdate(
          request,
          wallet.spreadsheet.spreadsheetId!,
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

  List<String> getMetadataForRow(int rowIndex, String key) {
    final metadata = data?[0].rowMetadata?[rowIndex].developerMetadata ?? [];
    return metadata
        .where((m) => m.metadataKey == key)
        .map((m) => m.metadataValue)
        .toList()
        .filterNonNull();
  }
}

extension _RowDataConverting on RowData {
  bool hasColumn(int column) => column < (values ?? []).length;

  double? getDouble({required int column}) {
    if (!hasColumn(column)) return null;
    return values?[column].effectiveValue?.numberValue;
  }

  String? getString({required int column}) {
    if (!hasColumn(column)) return null;
    final string = values?[column].effectiveValue?.stringValue;
    return string != null && string.isNotEmpty ? string : null;
  }

  DateTime? getDate({required int column}) {
    if (!hasColumn(column)) return null;
    final date = values?[column].effectiveValue?.numberValue;
    if (date == null) return null;

    final epoch = DateTime.utc(1899, 12, 30);
    return epoch.add(Duration(days: date.truncate()));
  }

  GoogleSpreadsheetTransactionType? getTransactionType({required int column}) {
    if (!hasColumn(column)) return null;
    final string = values?[column].effectiveValue?.stringValue;
    if (string == "Bieżące")
      return GoogleSpreadsheetTransactionType.current;
    else if (string == "Stałe")
      return GoogleSpreadsheetTransactionType.constant;
    else if (string == "Amortyzowane")
      return GoogleSpreadsheetTransactionType.depreciate;
    else
      return null;
  }
}
