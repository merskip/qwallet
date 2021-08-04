import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/oauth2/v2.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class GoogleOAuth2 {
  late final OAuth2Client _client;
  late OAuth2Helper _oauthHelper;

  GoogleOAuth2({
    required String clientId,
    required String packageName,
  }) {
    _client = GoogleOAuth2Client(
      customUriScheme: packageName,
      redirectUri: "$packageName:/oauth2redirect",
    );

    _oauthHelper = OAuth2Helper(_client,
        grantType: OAuth2Helper.AUTHORIZATION_CODE,
        clientId: clientId,
        scopes: [],
        authCodeParams: {
          "include_granted_scopes": "true",
        });
  }

  Future<OAuthCredential> signIn({
    List<String> scopes = const [],
  }) async {
    scopes.add(Oauth2Api.openidScope);
    _oauthHelper.scopes = scopes;
    final token = await _oauthHelper.fetchToken();
    return GoogleAuthProvider.credential(
      accessToken: token.accessToken,
      idToken: token.idToken,
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

  Future<bool> hasScope(List<String> scopes) async {
    final tokenScope = (await getLocalToken())?.scope;
    if (tokenScope == null) return false;
    for (final scope in scopes) {
      if (!tokenScope.contains(scope)) return false;
    }
    return true;
  }

  Future<AccessTokenResponse?> getLocalToken() async {
    _oauthHelper.scopes = await _getWidestScope(_oauthHelper);
    final token = await _oauthHelper.getTokenFromStorage();
    if (token == null) return null;
    return token.isValid() ? token : null;
  }

  Future<List<String>> _getWidestScope(OAuth2Helper helper) async {
    final serializedStoredTokens =
        await helper.tokenStorage.storage.read(helper.tokenStorage.key);
    if (serializedStoredTokens == null) return [];
    final Map<String, dynamic> storedTokens =
        jsonDecode(serializedStoredTokens);

    final scopes = storedTokens.values
        .map((value) => (value['scope'] as List).cast<String>());
    if (scopes.isEmpty) return [];

    final longestScope =
        scopes.reduce((lhs, rhs) => rhs.length > lhs.length ? rhs : lhs);
    return longestScope;
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
