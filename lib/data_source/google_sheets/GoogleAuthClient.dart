import 'package:http/http.dart' as http;

class GoogleAuthClient extends http.BaseClient {
  final _client = new http.Client();
  Map<String, String> authHeaders;

  GoogleAuthClient(this.authHeaders);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(authHeaders));
  }
}
