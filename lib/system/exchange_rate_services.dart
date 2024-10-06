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

static Future<void> updateExchangeRates() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> currencies = ["EUR", "TRY", "PLN"];

  for (int u = 0; u < currencies.length; u++) {
    for (int v = u + 1; v < currencies.length; v++) {
      // Sadece tek bir istek yap (örn. EUR-TRY)
      double? rate = await fetchExchangeRates(currencies[u], currencies[v]);

      if (rate != null) {
        String key1 = "${currencies[u]}-${currencies[v]}-rate";
        String key2 = "${currencies[v]}-${currencies[u]}-rate";

        // İki yönlü oranları hesapla ve kaydet
        prefs.setDouble(key1, rate);
        prefs.setDouble(key2, 1 / rate); // Ters oran

        // Oranların güncellenme tarihini kaydet
        String currentDate = DateTime.now().toString();
        prefs.setString("$key1-date", currentDate);
        prefs.setString("$key2-date", currentDate);

        // Log işlemi
        print("${currencies[u]}-${currencies[v]} rate: $rate");
        print("${currencies[v]}-${currencies[u]} rate: ${1 / rate}");
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
