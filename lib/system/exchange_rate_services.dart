import 'dart:convert';
import 'package:http/http.dart' as http;

import 'constants.dart';

class ExchangeRateService {
  static String access_key = apiKey;
  static String urlCurs = "https://api.freecurrencyapi.com/v1/latest";

  static Future<double?> fetchExchangeRates(
      String base, String currency) async {
    final response = await http.get(Uri.parse(
        "$urlCurs?apikey=$access_key&currencies=$currency&base_currency=$base"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'][currency];
    } else {
      return null;
    }
  }

  static Future<double?> showRates(String from, String to) async {
    double? rate = await fetchExchangeRates(from, to);
    return rate ?? 0.0;
  }
}
