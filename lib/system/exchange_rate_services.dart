import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ExchangeRateService {
  static String access_key = apiKey;
  static String urlCurs = "https://api.freecurrencyapi.com/v1/latest";

  static Future fetchExchangeRates(String base, String currency) async {
    final response = await http.get(Uri.parse(
        "$urlCurs?apikey=$access_key&currencies=$currency&base_currency=$base"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'][currency];
    } else {
      return null;
    }
  }

  // static Future<double?> showRates(String from, String to) async {
  //   double? rate = await fetchExchangeRates(from, to);
  //   return rate ?? 0.0;
  // }

  // static Future<void> updateRatesEvery1HourAnd10Min() async {
  //   Timer.periodic(const Duration(hours: 1, minutes: 10), (timer) async {
  //     await updateExchangeRates();
  //   });
  // }

  static Future<void> updateExchangeRates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currencies = ["EUR", "TRY", "PLN"];

    for (int u = 0; u < currencies.length; u++) {
      for (int v = u + 1; v < currencies.length; v++) {
        double? rate1 = await fetchExchangeRates(currencies[u], currencies[v]);
        double? rate2 = await fetchExchangeRates(currencies[v], currencies[u]);

        if (rate1 != null && rate2 != null) {
          String key1 = "${currencies[u]}-${currencies[v]}-rate";
          String key2 = "${currencies[v]}-${currencies[u]}-rate";
          prefs.setDouble(key1, rate1);
          prefs.setDouble(key2, rate2);
          prefs.setString("$key1-date", DateTime.now().toString());
          prefs.setString("$key2-date", DateTime.now().toString());

          // Log rate updates
          print("${currencies[u]}-${currencies[v]} rate: $rate1");
          print("${currencies[v]}-${currencies[u]} rate: $rate2");
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
