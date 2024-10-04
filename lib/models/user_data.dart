import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../system/exchange_rate_services.dart';

class UserData extends ChangeNotifier {
  DateTime? startDate;
  DateTime? endDate;
  double totalBalance = 0;
  late double dailySpendable;
  late double weeklySpendable;
  late double monthlySpendable;
  late double totalBalanceEUR;
  late double totalBalanceTRY;
  late double totalBalancePLN;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, double> balances = {
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
      startDate = userData?['startDate']?.toDate();
      endDate = userData?['endDate']?.toDate();
      balances = {
        'EUR': userData?['InitialBalance']['EUR'],
        'TRY': userData?['InitialBalance']['TRY'],
        'PLN': userData?['InitialBalance']['PLN'],
      };
      notifyListeners();
    }
  }

  // double? showBalances(Map<String, double> balances, String currency) {
  //   switch (currency) {
  //     case 'EUR':
  //       return balances['EUR'];
  //     case 'TRY':
  //       return balances['TRY'];
  //     case 'PLN':
  //       return balances['PLN'];
  //     default:
  //       return balances['EUR'];
  //   }
  // }

  calculateSpendableamount(String currency) async {
    await fetchUserDetails();
    final user = await getUserDetails();
    Map<String, dynamic>? userDoc = user.data();
    int remainingDays = userDoc?['ErasmusRemainingDuration'];
    double amount = 0.0;
    await calculateTotalAmounntsOfEachCurrency(currency);
    if (currency == "EUR") {
      amount = totalBalanceEUR;
    }
    if (currency == "TRY") {
      amount = totalBalanceTRY;
    }
    if (currency == "PLN") {
      amount = totalBalancePLN;
    }
    dailySpendable = amount / remainingDays;
    weeklySpendable = amount / (remainingDays / 7);
    monthlySpendable = amount / (remainingDays / 30);
    // Save the calculated spendable amounts to Firestore
    await saveCalculatedValuesToFirestore();

    notifyListeners();
  }

  Future<void> saveBalancesToFirebase() async {
    if (currentUser == null) return;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({
      'InitialBalance': {
        'EUR': balances['EUR'],
        'TRY': balances['TRY'],
        'PLN': balances['PLN'],
      },
    });
  }

  Future<void> saveCalculatedValuesToFirestore() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({
      'totalBalanceEUR': totalBalanceEUR,
      'totalBalanceTRY': totalBalanceTRY,
      'totalBalancePLN': totalBalancePLN,
      'dailySpendable': dailySpendable,
      'weeklySpendable': weeklySpendable,
      'monthlySpendable': monthlySpendable,
    });
  }

  Future<void> fetchCalculatedValuesFromFirestore() async {
    final userDoc = await getUserDetails();
    final data = userDoc.data();
    if (data != null) {
      totalBalanceEUR = data['totalBalanceEUR'] ?? 0.0;
      totalBalanceTRY = data['totalBalanceTRY'] ?? 0.0;
      totalBalancePLN = data['totalBalancePLN'] ?? 0.0;
      dailySpendable = data['dailySpendable'] ?? 0.0;
      weeklySpendable = data['weeklySpendable'] ?? 0.0;
      monthlySpendable = data['monthlySpendable'] ?? 0.0;
      notifyListeners();
    }
  }

  calculateTotalAmounntsOfEachCurrency(String currency) async {
    await fetchCalculatedValuesFromFirestore();
    switch (currency) {
      case 'EUR':
        final tryToEur =
            await ExchangeRateService.showRates("TRY", "EUR") ?? 0.0;
        final plnToEur =
            await ExchangeRateService.showRates("PLN", "EUR") ?? 0.0;
        totalBalanceEUR = balances['EUR']! +
            (balances['TRY']! * tryToEur) +
            (balances['PLN']! * plnToEur);
        calculateSpendableamount(currency);
        await saveCalculatedValuesToFirestore();
        notifyListeners();
        return totalBalanceEUR;
      case 'TRY':
        final plnToTry =
            await ExchangeRateService.showRates("PLN", "TRY") ?? 0.0;
        final eurToTry =
            await ExchangeRateService.showRates("EUR", "TRY") ?? 0.0;
        totalBalanceTRY = balances['TRY']! +
            (balances['EUR']! * eurToTry) +
            (balances['PLN']! * plnToTry);
        calculateSpendableamount(currency);
        await saveCalculatedValuesToFirestore();
        notifyListeners();
        return totalBalanceTRY;
      case 'PLN':
        final tryToPln =
            await ExchangeRateService.showRates("TRY", "PLN") ?? 0.0;
        final eurToPln =
            await ExchangeRateService.showRates("EUR", "PLN") ?? 0.0;
        totalBalancePLN = balances['PLN']! +
            (balances['EUR']! * eurToPln) +
            (balances['TRY']! * tryToPln);
        calculateSpendableamount(currency);
        await saveCalculatedValuesToFirestore();
        notifyListeners();
        return totalBalancePLN;
      default:
        return null;
    }
  }
}
