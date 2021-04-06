import 'dart:async';

import 'package:googleapis/sheets/v4.dart';

import '../AccountProvider.dart';
import 'GoogleAuthClient.dart';

class SheetsApiProvider {
  final AccountProvider accountProvider;

  SheetsApiProvider({
    required this.accountProvider,
  });

  Future<SheetsApi> get sheetsApi async {
    final account = await accountProvider.getAccount().first;
    final googleAccount = account.googleAccount;
    if (googleAccount == null)
      return Future.error("account.googleAccount is null");
    final client = GoogleAuthClient(googleAccount);
    return SheetsApi(client);
  }
}
