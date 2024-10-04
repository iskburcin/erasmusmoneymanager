import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCurrency = 'TRY'; // Default currency
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userData = Provider.of<UserData>(context, listen: false);

    // Fetch stored balances and spendable amounts from Firestore
    await userData.fetchCalculatedValuesFromFirestore();

    // If necessary, recalculate balances and spendable amounts
    await userData.calculateTotalAmounntsOfEachCurrency(selectedCurrency);
    await userData.calculateSpendableamount(selectedCurrency);

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Balance (EUR): ${userData.totalBalanceEUR}'),
            Text('Total Balance (TRY): ${userData.totalBalanceTRY}'),
            Text('Total Balance (PLN): ${userData.totalBalancePLN}'),
            Text('Daily Spendable: ${userData.dailySpendable.toStringAsFixed(2)} EUR'),
            Text('Weekly Spendable: ${userData.weeklySpendable.toStringAsFixed(2)} EUR'),
            Text('Monthly Spendable: ${userData.monthlySpendable.toStringAsFixed(2)} EUR'),
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
