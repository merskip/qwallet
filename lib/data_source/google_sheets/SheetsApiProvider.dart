import 'dart:async';

import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';

import '../AccountProvider.dart';
import 'GoogleAuthClient.dart';

class GoogleApiProvider {
  final AccountProvider accountProvider;

  GoogleApiProvider(this.accountProvider);

  Future<SheetsApi> get sheetsApi async => SheetsApi(await client);

  Future<DriveApi> get driveApi async => DriveApi(await client);

  Future<GoogleAuthClient> get client async {
    final account = await accountProvider.getAccount().first;
    final googleAccount = account.googleAccount;
    if (googleAccount == null)
      return Future.error("account.googleAccount is null");
    final authHeaders = await googleAccount.authHeaders;
    return GoogleAuthClient(authHeaders);
  }
}
