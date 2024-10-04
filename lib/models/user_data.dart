import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../system/exchange_rate_services.dart';

class UserData extends ChangeNotifier {
  late double dailySpendable= 0.0;
  late double weeklySpendable= 0.0;
  late double monthlySpendable= 0.0;
  late double totalBalanceInEUR = 0.0;
  late double totalBalanceInTRY = 0.0;
  late double totalBalanceInPLN = 0.0;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, double> accountBalances = {
    'EUR': 0.0,
    'TRY': 0.0,
    'PLN': 0.0,
  };

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() {
    return FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  Future<void> fetchUserDetails() async {
    if (currentUser == null) return;
    final doc = await getUserDetails();
    if (doc.exists) {
      final userData = doc.data();
      accountBalances = {
        'EUR': userData?['InitialBalance']['EUR'],
        'TRY': userData?['InitialBalance']['TRY'],
        'PLN': userData?['InitialBalance']['PLN'],
      };
      totalBalanceInEUR = userData?['totalBalanceEUR'] ?? 0.0;
      totalBalanceInTRY = userData?['totalBalanceTRY'] ?? 0.0;
      totalBalanceInPLN = userData?['totalBalancePLN'] ?? 0.0;
      notifyListeners();
    }
  }

  calculateSpendableAmount(String currency) async {
    await fetchUserDetails();
    final user = await getUserDetails();
    Map<String, dynamic>? userDoc = user.data();
    int remainingDays = userDoc?['ErasmusRemainingDuration'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double totalBalance = 0.0;
    if (currency == 'EUR') totalBalance = totalBalanceInEUR;
    if (currency == 'TRY') totalBalance = totalBalanceInTRY;
    if (currency == 'PLN') totalBalance = totalBalanceInPLN;
    dailySpendable = totalBalance / remainingDays;
    weeklySpendable = totalBalance / (remainingDays / 7);
    monthlySpendable = totalBalance / (remainingDays / 30);
    // Save the calculated spendable amounts to Firestore
    // Store in local storage
    await prefs.setDouble('dailySpendable-$currency', dailySpendable);
    await prefs.setDouble('weeklySpendable-$currency', weeklySpendable);
    await prefs.setDouble('monthlySpendable-$currency', monthlySpendable);
    print('dailySpendable-$currency: $dailySpendable');
    print('weeklySpendable-$currency: $weeklySpendable');
    print('monthlySpendable-$currency: $monthlySpendable');
    notifyListeners();
  }

  Future<void> loadSpendableAmount(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dailySpendable = prefs.getDouble('dailySpendable-$currency') ?? 0.0;
    weeklySpendable = prefs.getDouble('weeklySpendable-$currency') ?? 0.0;
    monthlySpendable = prefs.getDouble('monthlySpendable-$currency') ?? 0.0;
    notifyListeners();
  }

  Future<void> saveBalancesToFirebase() async {
    if (currentUser == null) return;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({
      'InitialBalance': {
        'EUR': accountBalances['EUR'],
        'TRY': accountBalances['TRY'],
        'PLN': accountBalances['PLN'],
      },
    });
  }

  Future<void> saveCalculatedValuesToFirestore() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({
      'totalBalanceEUR': totalBalanceInEUR,
      'totalBalanceTRY': totalBalanceInTRY,
      'totalBalancePLN': totalBalanceInPLN,
    });
  }

  calculateTotalBalances(String currency) async {
    await fetchUserDetails(); // Ensure balances are loaded

    // Fetch conversion rates
    double tryToEur = await ExchangeRateService.showRates('TRY', 'EUR') ?? 0.0;
    double plnToEur = await ExchangeRateService.showRates('PLN', 'EUR') ?? 0.0;
    double eurToTry = await ExchangeRateService.showRates('EUR', 'TRY') ?? 0.0;
    double plnToTry = await ExchangeRateService.showRates('PLN', 'TRY') ?? 0.0;
    double eurToPln = await ExchangeRateService.showRates('EUR', 'PLN') ?? 0.0;
    double tryToPln = await ExchangeRateService.showRates('TRY', 'PLN') ?? 0.0;

    // Calculate total balances in EUR, TRY, and PLN
    totalBalanceInEUR = accountBalances['EUR']! +
        (accountBalances['TRY']! * tryToEur) +
        (accountBalances['PLN']! * plnToEur);
    totalBalanceInTRY = accountBalances['TRY']! +
        (accountBalances['EUR']! * eurToTry) +
        (accountBalances['PLN']! * plnToTry);
    totalBalanceInPLN = accountBalances['PLN']! +
        (accountBalances['EUR']! * eurToPln) +
        (accountBalances['TRY']! * tryToPln);
    calculateSpendableAmount(currency);
    await saveCalculatedValuesToFirestore();
    notifyListeners();
  }

}