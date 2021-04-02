import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleAuthClient extends http.BaseClient {
  final GoogleSignInAccount googleAccount;

  final http.Client _client = new http.Client();

  GoogleAuthClient(this.googleAccount);

  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final httpHeaders = await googleAccount.authHeaders;
    return _client.send(request..headers.addAll(httpHeaders));
  }
}
