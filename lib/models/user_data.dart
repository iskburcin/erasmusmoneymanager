import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String name = '';
  DateTime? startDate;
  DateTime? endDate;
  Map<String, double> balances = {'eur': 0.0, 'try': 0.0, 'pln': 0.0};
  double dailySpendable = 0.0;
  double weeklySpendable = 0.0;
  double monthlySpendable = 0.0;

Future<void> fetchUserData(String email) async {
    try {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(email)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        startDate = data['ErasmusStartDate'] ?? '';
        endDate = data['ErasmusEndDate'] ?? '';
        balances['eur'] = data['InitialBalance']['EUR']?.toDouble() ?? 0.0;
        balances['try'] = data['InitialBalance']['TRY']?.toDouble() ?? 0.0;
        balances['pln'] = data['InitialBalance']['PLN']?.toDouble() ?? 0.0;

        // Update spendable amounts (you can add your calculations here)
        // Example: 
        dailySpendable = balances['eur']! / 30; // For simplicity, assuming a 30-day month
        weeklySpendable = dailySpendable * 7;
        monthlySpendable = balances['eur']!;

        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }
  void updateBalances(Map<String, double> newBalances) {
    balances = newBalances;
    notifyListeners();
  }

  void calculateSpendableAmounts() {
    final totalBalanceEur = balances['eur']! + (balances['try']! / 10) + (balances['pln']! / 4.5); // Example rates
    Duration remainingDays = endDate!.difference(startDate!);

    if ((remainingDays as int) > 0) {
      dailySpendable = totalBalanceEur / (remainingDays as int);
      weeklySpendable = dailySpendable * 7;
      monthlySpendable = dailySpendable * 30;
    }
    notifyListeners();
  }

  int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}
}
