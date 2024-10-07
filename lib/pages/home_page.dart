import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_or_register.dart';
import '../models/user_data.dart';
import '../system/exchange_rate_services.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCurrency = 'EUR'; // Default currency
  String lastUpdated = 'Fetching..............';
  String nextUpdate = 'Calculating............';
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    Provider.of<UserData>(context, listen: false).listenToAuthChanges();
    loadUserData();
    initializeUpdateSchedule();
  }

  Future<void> loadUserData() async {
    final userData = Provider.of<UserData>(context, listen: false);
    await userData.calculateTotalBalances(selectedCurrency);
    await userData.loadSpendableAmount(selectedCurrency);
  }

  Future<void> initializeUpdateSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastUpdateTime = prefs.getString('lastUpdateTime');
    if (lastUpdateTime != null) {
      DateTime lastUpdatedDateTime = DateTime.parse(lastUpdateTime);
      DateTime nextUpdateDateTime =
          lastUpdatedDateTime.add(const Duration(hours: 1, minutes: 10));
      if (DateTime.now().isBefore(nextUpdateDateTime)) {
        // Show the last update and calculate next update
        setState(() {
          lastUpdated = lastUpdatedDateTime.toString();
          nextUpdate = nextUpdateDateTime.toString();
        });
      } else {
        await updateExchangeRates();
      }
    } else {
      // No previous update, perform first API call
      await updateExchangeRates();
    }

    // Start the periodic update schedule
    updateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      checkUpdateStatus();
    });
  }

  Future<void> checkUpdateStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastUpdateTime = prefs.getString('lastUpdateTime');
    if (lastUpdateTime != null) {
      DateTime lastUpdatedDateTime = DateTime.parse(lastUpdateTime);
      DateTime nextUpdateDateTime =
          lastUpdatedDateTime.add(const Duration(hours: 1, minutes: 10));

      if (DateTime.now().isAfter(nextUpdateDateTime)) {
        await updateExchangeRates();
      }
    }
  }

  Future<void> updateExchangeRates() async {
    await ExchangeRateService.updateExchangeRates();
    if (mounted) {
      setState(() {
        lastUpdated = DateTime.now().toString();
        nextUpdate = DateTime.now()
            .add(const Duration(hours: 1, minutes: 10))
            .toString();
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastUpdateTime', DateTime.now().toString());
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
            child: SingleChildScrollView(
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
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    "Hesap Bakiyeleri",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  // Scrollable row for account balances
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildBalanceCard(
                            userData.accountBalances["EUR"]!, 'EUR'),
                        buildBalanceCard(
                            userData.accountBalances["TRY"]!, 'TRY'),
                        buildBalanceCard(
                            userData.accountBalances["PLN"]!, 'PLN'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    "Para Birimine Göre Toplam Bakiye",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  // Scrollable row for total balances in different currencies
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildBalanceCard(userData.totalBalances['EUR']!, 'EUR'),
                        buildBalanceCard(userData.totalBalances['TRY']!, 'TRY'),
                        buildBalanceCard(userData.totalBalances['PLN']!, 'PLN'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildSpendableCards(userData),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Döviz Kurları",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      buildLastUpdatedFooter(),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildExchangeRateGrid(),
                ],
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
              await signOut(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const LoginOrRegister()),
              );
              // Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Exchange rate grid
  Widget buildExchangeRateGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns
        childAspectRatio: 1.5, // Makes sure the boxes are square
      ),
      itemCount: 6, // Number of rate pairs to show
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[850],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getRatePairName(index),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                FutureBuilder<double?>(
                  future: getRateByIndex(index),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Loading...',
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!.toStringAsFixed(2),
                        style: const TextStyle(color: Colors.white70),
                      );
                    }
                    return const Text('Error',
                        style: TextStyle(color: Colors.red));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to get rate pair names
  String getRatePairName(int index) {
    List<String> ratePairs = [
      'EUR/TRY',
      'EUR/PLN',
      'PLN/TRY',
      'TRY/EUR',
      'PLN/EUR',
      'TRY/PLN'
    ];
    return ratePairs[index];
  }

  Future<double?> getRateByIndex(int index) async {
    switch (index) {
      case 0:
        return await ExchangeRateService.getRateFromCache('EUR', 'TRY');
      case 1:
        return await ExchangeRateService.getRateFromCache('EUR', 'PLN');
      case 2:
        return await ExchangeRateService.getRateFromCache('PLN', 'TRY');
      case 3:
        return await ExchangeRateService.getRateFromCache('TRY', 'EUR');
      case 4:
        return await ExchangeRateService.getRateFromCache('PLN', 'EUR');
      case 5:
        return await ExchangeRateService.getRateFromCache('TRY', 'PLN');
      default:
        return null;
    }
  }

  // Last Updated and Next Update information
  Widget buildLastUpdatedFooter() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Last Updated: ${lastUpdated.substring(0, 16)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Next Update: ${nextUpdate.substring(0, 16)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Card buildBalanceCard(double balance, String currency) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 120, // Adjust card width for better scrollability
        child: ListTile(
          title: Text(currency, style: const TextStyle(color: Colors.white)),
          subtitle: Text('${balance.toStringAsFixed(2)} $currency',
              style: const TextStyle(color: Colors.white70)),
        ),
      ),
    );
  }

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

  Widget buildSpendableCards(UserData userData) {
    return Column(
      children: [
        buildSpendableCard(userData.dailySpendable, 'Günlük', selectedCurrency),
        buildSpendableCard(
            userData.weeklySpendable, 'Haftalık', selectedCurrency),
        buildSpendableCard(
            userData.monthlySpendable, 'Aylık', selectedCurrency),
      ],
    );
  }
  Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  
  // Kullanıcı çıkış yaptıktan sonra userData verisini sıfırla
  Provider.of<UserData>(context, listen: false).clearData();
}

}
