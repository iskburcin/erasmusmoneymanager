import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';
// Assuming this exists for profile management

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCurrency = 'EUR'; // Default currency
  double totalExpenses = 0;
  double totalIncome = 0;
  double totalBalance = 0;
  int currentPageIndex = 0;
  

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Balance (EUR): ${userData.balances['eur']}'),
            Text(
                'Daily Spendable: ${userData.dailySpendable.toStringAsFixed(2)} EUR'),
            Text(
                'Weekly Spendable: ${userData.weeklySpendable.toStringAsFixed(2)} EUR'),
            Text(
                'Monthly Spendable: ${userData.monthlySpendable.toStringAsFixed(2)} EUR'),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Total Money Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Navigator.pop(context);
              await _auth.signOut();
            },
          ),
        ],
      ),
    );
  }


}
