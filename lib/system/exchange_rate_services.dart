import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static Future<Map<String, double>> fetchExchangeRates() async {
    final response = await http.get(Uri.parse('https://api.exchangeratesapi.io/latest?base=EUR'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Map<String, double>.from(data['rates']);
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }
}
