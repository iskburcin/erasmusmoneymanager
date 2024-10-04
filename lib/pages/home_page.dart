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
  String selectedCurrency = 'EUR'; // Default currency
  String lastUpdated = 'Fetching...';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userData = Provider.of<UserData>(context, listen: false);
    await userData.fetchUserDetails();
    await userData.loadSpendableAmount(selectedCurrency);
    await userData.calculateTotalBalances(selectedCurrency);
    await userData.calculateSpendableAmount(selectedCurrency);
    if (mounted) {
      setState(() {
        lastUpdated = DateTime.now().toLocal().toString(); // Set update time
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: selectedCurrency,
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  items: ['EUR', 'TRY', 'PLN']
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) async {
                    setState(() {
                      selectedCurrency = value!;
                    });
                    await userData.calculateSpendableAmount(selectedCurrency);
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Hesap Bakiyeleri",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16,
                ),
                // Scrollable row for account balances
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      buildAccountBalanceCard(
                          'EUR', userData.accountBalances["EUR"]),
                      buildAccountBalanceCard(
                          'TRY', userData.accountBalances["TRY"]),
                      buildAccountBalanceCard(
                          'PLN', userData.accountBalances["PLN"]),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Toplam Bakiye",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16,
                ),
                // Scrollable row for total balances in different currencies
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      buildTotalBalanceCard(userData.totalBalanceInEUR, 'EUR'),
                      buildTotalBalanceCard(userData.totalBalanceInTRY, 'TRY'),
                      buildTotalBalanceCard(userData.totalBalanceInPLN, 'PLN'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Spendable amounts section
                buildSpendableCard(
                    userData.dailySpendable, 'Günlük', selectedCurrency),
                buildSpendableCard(
                    userData.weeklySpendable, 'Haftalık', selectedCurrency),
                buildSpendableCard(
                    userData.monthlySpendable, 'Aylık', selectedCurrency),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Last Updated: $lastUpdated',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Paralarım Ne Durumda ?'),
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

  // Card for individual account balance
  Card buildAccountBalanceCard(String currency, double? balance) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 150, // Adjust card width for better scrollability
        child: ListTile(
          title: Text('$currency', style: const TextStyle(color: Colors.white)),
          subtitle: Text('${balance?.toStringAsFixed(2)} $currency',
              style: const TextStyle(color: Colors.white70)),
        ),
      ),
    );
  }

  // Card for total balances in a specific currency
  Card buildTotalBalanceCard(double balance, String currency) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 150, // Adjust card width for better scrollability
        child: ListTile(
          title:
              Text('($currency)', style: const TextStyle(color: Colors.white)),
          subtitle: Text('${balance.toStringAsFixed(2)} $currency',
              style: const TextStyle(color: Colors.white70)),
        ),
      ),
    );
  }

  // Card for daily, weekly, or monthly spendable amounts
  Card buildSpendableCard(double spendable, String period, String currency) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text('$period Harcanabilir Miktar',
            style: const TextStyle(color: Colors.white)),
        subtitle: Text('${spendable.toStringAsFixed(2)} $currency',
            style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}
