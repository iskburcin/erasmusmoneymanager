import 'package:flutter/material.dart';

class TotalBox extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;

  const TotalBox({super.key,
    required this.title,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("$amount $currency", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)],
          )
        ],
      ),
    );
  }
}
