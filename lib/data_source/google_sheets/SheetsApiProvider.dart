import 'dart:async';

import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/features/sign_in/AuthSuite.dart';

import '../AccountProvider.dart';
import 'GoogleAuthClient.dart';

class GoogleApiProvider {
  final AccountProvider accountProvider;

  GoogleApiProvider(this.accountProvider);

  Future<SheetsApi> get sheetsApi async => SheetsApi(await client);

  Future<DriveApi> get driveApi async => DriveApi(await client);

  Future<GoogleAuthClient> get client async {
    final authHeaders = await AuthSuite.instance.getAuthHeaders();
    return GoogleAuthClient(authHeaders);
  }
}
