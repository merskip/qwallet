import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WhitelistAPI {
  final String baseUrl;

  WhitelistAPI({this.baseUrl = "https://wl-api.mf.gov.pl/api/"});

  Future<String> fetchEntityNameByNip(String nip) async {
    final url = "$baseUrl/search/nip/$nip?date=${_getDateNow()}";
    debugPrint("Fetching url: $url");
    final response = await http.get(Uri.dataFromString(url));
    final content = json.decode(response.body);
    return content["result"]["subject"]["name"];
  }

  String _getDateNow() => DateFormat("yyyy-MM-dd").format(DateTime.now());
}
