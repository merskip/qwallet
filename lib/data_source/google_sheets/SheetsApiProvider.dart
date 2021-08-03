import 'dart:async';

import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/features/sign_in/AuthSuite.dart';

import 'GoogleAuthClient.dart';

class GoogleApiProvider {
  final AuthSuite authSuite;

  GoogleApiProvider(this.authSuite);

  Future<SheetsApi> get sheetsApi async => SheetsApi(await client);

  Future<DriveApi> get driveApi async => DriveApi(await client);

  Future<GoogleAuthClient> get client async {
    final authHeaders = await authSuite.getAuthHeaders();
    return GoogleAuthClient(authHeaders);
  }
}
