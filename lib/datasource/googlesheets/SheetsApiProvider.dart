import 'dart:async';

import 'package:googleapis/sheets/v4.dart';

import '../AccountProvider.dart';
import 'GoogleAuthClient.dart';

class SheetsApiProvider {
  final AccountProvider accountProvider;

  SheetsApiProvider({
    required this.accountProvider,
  });

  Future<T> onSheetsApi<T>(
      FutureOr<T> Function(SheetsApi sheetsApi) callback) async {
    final account = await accountProvider.getAccount();
    final client = GoogleAuthClient(account.googleAccount!);
    final sheetsApi = SheetsApi(client);
    return callback(sheetsApi);
  }
}
