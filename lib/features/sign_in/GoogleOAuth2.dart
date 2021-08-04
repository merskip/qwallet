import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/oauth2/v2.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class GoogleOAuth2 {
  late final OAuth2Client _client;
  late final OAuth2Helper _oauthHelper;

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
      scopes: [
        Oauth2Api.userinfoProfileScope,
      ],
    );
  }

  Future<AccessTokenResponse?> getLocalToken() async {
    final token = await _oauthHelper.getTokenFromStorage();
    if (token == null) return null;
    return token.isValid() ? token : null;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _oauthHelper.getTokenFromStorage();
    final accessToken = token?.accessToken;
    if (accessToken == null) return Future.error("No access token");

    return <String, String>{
      "Authorization": "Bearer $accessToken",
      "X-Goog-AuthUser": "0",
    };
  }

  Future<OAuthCredential> signIn() async {
    final token = await _oauthHelper.fetchToken();
    return GoogleAuthProvider.credential(
      accessToken: token.accessToken,
      idToken: token.idToken,
    );
  }

  Future<void> signOut() async {
    await _oauthHelper.disconnect();
  }
}

extension AccessTokenResponseIdToken on AccessTokenResponse {
  String? get idToken {
    return isValid() ? respMap['id_token'] : null;
  }
}
