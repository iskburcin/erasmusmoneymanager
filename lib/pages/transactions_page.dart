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
    double? balance = userData.accountBalances[selectedCurrency];
    if (isExpense) {
      balance = balance! - amount;
    } else {
      balance = balance! + amount;
    }
    userData.calculateSpendableAmount;
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Transactions         I Ş L E M L E R I M'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              decoration: InputDecoration(
                  hintText: 'Kaç para?',
                  hintStyle: TextStyle(color: Colors.grey[600])),
              keyboardType: TextInputType.number,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Gider'),
                Switch(
                  value: isExpense,
                  onChanged: (value) {
                    setState(() {
                      isExpense = value;
                    });
                  },
                ),
                Text('Gelir'),
              ],
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[800])),
              onPressed: () {
                addTransaction(userData);
              },
              child: Text('Işlemi Gönder',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}
