import 'dart:math';

import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class GoogleSignInOAuth2 {
  final String codeVerifier;

  GoogleSignInOAuth2() : codeVerifier = createCodeVerifier();

  static String createCodeVerifier() {
    final charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return List.generate(
        128, (i) => charset[Random.secure().nextInt(charset.length)]).join();
  }

  Future<void> requestAuthentication() async {
    print("Creating GoogleOAuth2Client");
    final client = GoogleOAuth2Client(
      customUriScheme: 'pl.merskip.qwallet',
      redirectUri: 'pl.merskip.qwallet:/oauth2redirect',
    );
    print("- Created GoogleOAuth2Client");

    print("Creating OAuth2Helper");
    final oauth2Helper = OAuth2Helper(
      client,
      grantType: OAuth2Helper.AUTHORIZATION_CODE,
      clientId:
          '207455736812-iivopmrkc4trb5pqpg5h5m10rjbcgiee.apps.googleusercontent.com',
      scopes: ['https://www.googleapis.com/auth/userinfo.profile'],
    );
    print("- Created OAuth2Helper");

    final token = await oauth2Helper.getToken();

    final response =
        await oauth2Helper.get("https://www.googleapis.com/oauth2/v2/userinfo");
    print(response.body);
  }
}
