import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../system/exchange_rate_services.dart';

class UserData extends ChangeNotifier {
  late double dailySpendable = 0.0;
  late double weeklySpendable = 0.0;
  late double monthlySpendable = 0.0;
  int remainingDays = 0; // Store calculated remaining days
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, double> accountBalances = {
    'EUR': 0.0,
    'TRY': 0.0,
    'PLN': 0.0,
  };
  Map<String, double> totalBalances = {
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
        'EUR': userData?['InitialBalance'] != null
            ? double.tryParse(
                    (userData?['InitialBalance']['EUR']).toString()) ??
                0.0
            : 0.0,
        'TRY': userData?['InitialBalance'] != null
            ? double.tryParse(
                    (userData?['InitialBalance']['TRY']).toString()) ??
                0.0
            : 0.0,
        'PLN': userData?['InitialBalance'] != null
            ? double.tryParse(
                    (userData?['InitialBalance']['PLN']).toString()) ??
                0.0
            : 0.0,
      };

      totalBalances = {
        'EUR': userData?['totalBalances'] != null
            ? double.tryParse((userData?['totalBalances']['EUR']).toString()) ??
                0.0
            : 0.0,
        'TRY': userData?['totalBalances'] != null
            ? double.tryParse((userData?['totalBalances']['TRY']).toString()) ??
                0.0
            : 0.0,
        'PLN': userData?['totalBalances'] != null
            ? double.tryParse((userData?['totalBalances']['PLN']).toString()) ??
                0.0
            : 0.0,
      };

      // Calculate the remaining Erasmus days
      DateTime endDate = DateTime.parse(userData?['ErasmusEndDate']);
      remainingDays = endDate.difference(DateTime.now()).inDays;

      // If the Erasmus period has ended, set remainingDays to 0
      if (remainingDays < 0) {
        remainingDays = 0;
      }

      notifyListeners();
    }
  }

  calculateSpendableAmount(String currency) async {
    await fetchUserDetails();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? totalBalance = 0.0;
    if (currency == 'EUR') totalBalance = totalBalances['EUR'];
    if (currency == 'TRY') totalBalance = totalBalances['TRY'];
    if (currency == 'PLN') totalBalance = totalBalances['PLN'];
    dailySpendable = totalBalance! / remainingDays;
    weeklySpendable = totalBalance / (remainingDays / 7);
    monthlySpendable = totalBalance / (remainingDays / 30);
    // Store in local storage
    await prefs.setDouble('dailySpendable-$currency', dailySpendable);
    await prefs.setDouble('weeklySpendable-$currency', weeklySpendable);
    await prefs.setDouble('monthlySpendable-$currency', monthlySpendable);
    notifyListeners();
  }

  Future<void> loadSpendableAmount(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dailySpendable = prefs.getDouble('dailySpendable-$currency') ?? 0.0;
    weeklySpendable = prefs.getDouble('weeklySpendable-$currency') ?? 0.0;
    monthlySpendable = prefs.getDouble('monthlySpendable-$currency') ?? 0.0;
    notifyListeners();
  }

  Future<void> saveCalculatedValuesToFirestore() async {
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
      'totalBalances': {
        'EUR': totalBalances['EUR'],
        'TRY': totalBalances['TRY'],
        'PLN': totalBalances['PLN'],
      },
    });
  }

  calculateTotalBalances(String currency) async {
    await fetchUserDetails(); // Ensure balances are loaded

    // Fetch conversion rates
    double tryToEur =
        await ExchangeRateService.getRateFromCache('TRY', 'EUR') ?? 0.0;
    double plnToEur =
        await ExchangeRateService.getRateFromCache('PLN', 'EUR') ?? 0.0;
    double eurToTry =
        await ExchangeRateService.getRateFromCache('EUR', 'TRY') ?? 0.0;
    double plnToTry =
        await ExchangeRateService.getRateFromCache('PLN', 'TRY') ?? 0.0;
    double eurToPln =
        await ExchangeRateService.getRateFromCache('EUR', 'PLN') ?? 0.0;
    double tryToPln =
        await ExchangeRateService.getRateFromCache('TRY', 'PLN') ?? 0.0;

    // Calculate total balances in EUR, TRY, and PLN
    totalBalances['EUR'] = accountBalances['EUR']! +
        (accountBalances['TRY']! * tryToEur) +
        (accountBalances['PLN']! * plnToEur);
    totalBalances['TRY'] = accountBalances['TRY']! +
        (accountBalances['EUR']! * eurToTry) +
        (accountBalances['PLN']! * plnToTry);
    totalBalances['PLN'] = accountBalances['PLN']! +
        (accountBalances['EUR']! * eurToPln) +
        (accountBalances['TRY']! * tryToPln);
    calculateSpendableAmount(currency);
    await saveCalculatedValuesToFirestore();
    notifyListeners();
  }

  void clearData() async {
    dailySpendable = 0.0;
    weeklySpendable = 0.0;
    monthlySpendable = 0.0;
    remainingDays = 0;

    accountBalances = {
      'EUR': 0.0,
      'TRY': 0.0,
      'PLN': 0.0,
    };

    totalBalances = {
      'EUR': 0.0,
      'TRY': 0.0,
      'PLN': 0.0,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Tüm SharedPreferences verilerini temizliyoruz

    notifyListeners();
  }

  void listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // Kullanıcı çıkış yapmışsa, verileri temizle
        clearData();
      } else {
        // Yeni bir kullanıcı giriş yaptıysa, currentUser'ı güncelle
        currentUser = user;
        fetchUserDetails();
      }
    });
  }
}
