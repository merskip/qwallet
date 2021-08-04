import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/oauth2/v2.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class GoogleOAuth2 {
  late final OAuth2Client _client;
  late OAuth2Helper _oauthHelper;

  final _minimumScope = <String>[
    Oauth2Api.userinfoProfileScope,
  ];

  final _googleSheetScope = <String>[
    Oauth2Api.userinfoProfileScope,
    DriveApi.driveReadonlyScope,
    SheetsApi.spreadsheetsScope
  ];

  GoogleOAuth2({
    required String clientId,
    required String packageName,
  }) {
    _client = GoogleOAuth2Client(
      customUriScheme: packageName,
      redirectUri: "$packageName:/oauth2redirect",
    );

    _oauthHelper = OAuth2Helper(
      _client,
      grantType: OAuth2Helper.AUTHORIZATION_CODE,
      clientId: clientId,
      scopes: _minimumScope,
    );
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getLocalToken();
    final accessToken = token?.accessToken;
    if (accessToken == null) return Future.error("No access token");

    return <String, String>{
      "Authorization": "Bearer $accessToken",
      "X-Goog-AuthUser": "0",
    };
  }

  Future<bool> hasGoogleSheetsPermission() async {
    final scope = (await getLocalToken())?.scope;
    if (scope == null) return false;
    return scope.contains(DriveApi.driveReadonlyScope) &&
        scope.contains(SheetsApi.spreadsheetsScope);
  }

  Future<AccessTokenResponse?> getLocalToken() async {
    _oauthHelper.scopes = await _getWidestScope(_oauthHelper);
    final token = await _oauthHelper.getTokenFromStorage();
    if (token == null) return null;
    return token.isValid() ? token : null;
  }

  Future<List<String>> _getWidestScope(OAuth2Helper helper) async {
    final tokenWithSheets =
        await helper.tokenStorage.getToken(_googleSheetScope);
    return tokenWithSheets != null ? _googleSheetScope : _minimumScope;
  }

  Future<OAuthCredential> signIn() async {
    final token = await _oauthHelper.fetchToken();
    return GoogleAuthProvider.credential(
      accessToken: token.accessToken,
      idToken: token.idToken,
    );
  }

  Future<void> requestGoogleSheetPermissions() {
    _oauthHelper.scopes = _googleSheetScope;
    _oauthHelper.authCodeParams = {
      "include_granted_scopes": "true",
    };
    return _oauthHelper.fetchToken();
  }

  Future<void> signOut() async {
    await _oauthHelper.disconnect();
    await _oauthHelper.removeAllTokens();
  }
}

extension AccessTokenResponseIdToken on AccessTokenResponse {
  String? get idToken {
    return isValid() ? respMap['id_token'] : null;
  }
}
