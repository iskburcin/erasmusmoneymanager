import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ExchangeRateService {
  static String access_key = apiKey;
  static String urlCurs = "https://api.freecurrencyapi.com/v1/latest";

  static Future fetchExchangeRates(
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

  static Future<void> updateRatesEvery10Minutes() async {
    Timer.periodic(Duration(minutes: 10), (timer) async {
      await updateExchangeRates();
    });
  }

  static Future<void> updateExchangeRates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currencies = ["EUR", "TRY", "PLN"];

    for (var u = 0; currencies.length >= u; u++) {
      for (var v = 2; 0 <= v; v--) {
        if (currencies[u] != currencies[v]) {
          double rate = await fetchExchangeRates(currencies[u], currencies[v]);
          String key = "${currencies[u]}-${currencies[v]}-rate";
          prefs.setDouble(key, rate); // Save rate
          prefs.setString("$key-date", DateTime.now().toString()); // Save date
          print("${currencies[u]}-${currencies[v]} rates: $rate");
        } else {
          continue;
        }
      }
    }
  }

  static Future<double?> getRateFromCache(String base, String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = "$base-$currency-rate";
    return prefs.getDouble(key);
  }

  static Future<String?> getRateFetchDate(String base, String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = "$base-$currency-rate-date";
    return prefs.getString(key);
  }
}
