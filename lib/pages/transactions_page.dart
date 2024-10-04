import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String selectedCurrency = 'eur';
  final amountController = TextEditingController();
  bool isExpense = true;

  void addTransaction(UserData userData) {
    final amount = double.parse(amountController.text);
    double? balance = userData.balances[selectedCurrency];
    if (isExpense) {
      balance = balance! - amount;
    } else {
      balance = balance! + amount;
    }
    userData.calculateSpendableamount;
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedCurrency,
            items: ['eur', 'try', 'pln'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCurrency = newValue!;
              });
            },
          ),
          TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Expense'),
              Switch(
                value: isExpense,
                onChanged: (value) {
                  setState(() {
                    isExpense = value;
                  });
                },
              ),
              Text('Income'),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              addTransaction(userData);
            },
            child: Text('Submit Transaction'),
          ),
        ],
      ),
    );
  }
}
