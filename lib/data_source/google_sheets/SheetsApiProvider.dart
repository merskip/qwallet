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
    final account = accountProvider.account;
    if (account == null) throw ("accountProvider.account is null");

    final googleAccount = account.googleAccount;
    if (googleAccount == null) throw ("account.googleAccount is null");

    final authHeaders = await googleAccount.authHeaders;
    return GoogleAuthClient(authHeaders);
  }
}
