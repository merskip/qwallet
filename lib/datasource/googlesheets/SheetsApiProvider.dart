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
    final account = await accountProvider.getAccount();
    final googleAccount = account.googleAccount;
    if (googleAccount == null) throw Exception("account.googleAccount is null");

    final client = GoogleAuthClient(googleAccount);
    return SheetsApi(client);
  }
}
