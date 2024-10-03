import 'package:erasmusmoneymanager/models/transaction.dart';
import 'package:flutter/material.dart';

class EntryCard extends StatelessWidget {
  final ItemCategoryType title;
  final double amount;
  final TransactionType type;
  final String currency;
  final DateTime? time;
  const EntryCard(
      {super.key,
      required this.title,
      required this.amount,
      required this.type,
      required this.currency,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Card(
        child: ListTile(
          title: Text(
            title as String,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          trailing: Text(
            type == "income" ? "$amount $currency" : "-$amount $currency",
            style: TextStyle(
              fontSize: 20,
              color: type == "income"? Colors.green : Colors.red
            ),
          ),
        ),
      ),
    );
  }
}
