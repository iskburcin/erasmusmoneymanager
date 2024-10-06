import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String selectedCurrency = 'EUR';
  String? selectedExpenseCategory;
  String? selectedIncomeCategory;
  String? manualCategory; // For 'other' manual category
  final amountController = TextEditingController();
  bool isExpense = false;
  List<Map<String, dynamic>> transactionHistory = [];

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

void addTransaction(UserData userData) async {
  final amount = double.parse(amountController.text);
  double? balance = userData.accountBalances[selectedCurrency];

  if (isExpense) {
    balance = balance! - amount;
    selectedExpenseCategory ??= 'Other';
  } else {
    balance = balance! + amount;
    selectedIncomeCategory ??= 'Other';
  }

  // Create a transaction entry
  final transaction = {
    'type': isExpense ? 'Expense' : 'Income',
    'category': manualCategory ??
        (isExpense ? selectedExpenseCategory : selectedIncomeCategory),
    'amount': amount,
    'currency': selectedCurrency,
    'timestamp': DateTime.now().toIso8601String(), // Save time for sorting
  };

  // Add transaction to Firebase
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userData.currentUser!.email) // Make sure userData.uid contains the current user's id
      .collection('Transactions')
      .add(transaction);

  // Update the specific currency balance in Firebase without overwriting other currencies
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userData.currentUser!.email)
      .update({
        'InitialBalance.$selectedCurrency': balance, // Update only the selected currency
      });

  // Update the local userData to reflect the changes
  userData.accountBalances[selectedCurrency] = balance;
  userData.calculateTotalBalances(selectedCurrency);
  userData.calculateSpendableAmount(selectedCurrency);

  // Clear inputs
  setState(() {
    amountController.clear();
    manualCategory = null;
    selectedExpenseCategory = null;
    selectedIncomeCategory = null;
  });
}


  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Transactions         I Ş L E M L E R I M'),
      ),
      body: Expanded(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<String>(
                        value: selectedCurrency.isNotEmpty &&
                                ['EUR', 'TRY', 'PLN'].contains(selectedCurrency)
                            ? selectedCurrency
                            : 'EUR', // Set a fallback value if something goes wrong
                        dropdownColor: Colors.grey[800],
                        iconEnabledColor: isExpense ? Colors.red : Colors.green,
                        style: const TextStyle(color: Colors.white),
                        items: ['EUR', 'TRY', 'PLN'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toUpperCase(),
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCurrency = newValue!;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Gelir', style: TextStyle(color: Colors.green)),
                          Switch(
                            value: isExpense,
                            onChanged: (value) {
                              setState(() {
                                isExpense = value;
                                manualCategory = null; // Reset manual category
                              });
                            },
                            inactiveThumbColor: Colors.green,
                            inactiveTrackColor: Colors.green[200],
                            activeColor: Colors.red,
                            activeTrackColor: Colors.red[200],
                            trackOutlineColor: WidgetStatePropertyAll(
                                isExpense ? Colors.red[200] : Colors.green[200]),
                          ),
                          const Text('Gider', style: TextStyle(color: Colors.red)),
                          const SizedBox(
                            width: 30,
                          ),
                          isExpense
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButton<String>(
                                      value: selectedExpenseCategory,
                                      dropdownColor: Colors.grey[900],
                                      iconEnabledColor:
                                          isExpense ? Colors.red : Colors.green,
                                      style: const TextStyle(color: Colors.white),
                                      hint: const Text('Gider Kategorisi Seç',
                                          style: TextStyle(color: Colors.red)),
                                      items: [
                                        'Market',
                                        'Giyim',
                                        'Yemek',
                                        'Ulaşım',
                                        'Konaklama',
                                        'Other'
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedExpenseCategory = newValue;
                                          manualCategory =
                                              null; // Reset if "other" isn't selected
                                        });
                                      },
                                    ),
                                    if (selectedExpenseCategory == 'Other')
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Gider türünü girin',
                                          hintStyle:
                                              TextStyle(color: Colors.grey[600]),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            manualCategory = value;
                                          });
                                        },
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButton<String>(
                                      value: selectedIncomeCategory,
                                      dropdownColor: Colors.grey[900],
                                      iconEnabledColor:
                                          isExpense ? Colors.red : Colors.green,
                                      style: const TextStyle(color: Colors.white),
                                      hint: const Text('Gelir Kategorisi Seç',
                                          style: TextStyle(color: Colors.green)),
                                      items: [
                                        'Aile',
                                        'Hibe',
                                        'İş',
                                        'İşbank',
                                        'Alınan Borç',
                                        'Other'
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedIncomeCategory = newValue;
                                          manualCategory =
                                              null; // Reset if "other" isn't selected
                                        });
                                      },
                                    ),
                                    if (selectedIncomeCategory == 'Other')
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Gelir türünü girin',
                                          hintStyle:
                                              TextStyle(color: Colors.grey[600]),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            manualCategory = value;
                                          });
                                        },
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: isExpense
                                    ? Colors.red[200]!
                                    : Colors.green[200]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: isExpense
                                    ? Colors.red[200]!
                                    : Colors.green[200]!)),
                        hintText: "Kaç para?",
                        hintStyle: const TextStyle(color: Colors.grey)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    onPressed: () {
                      if (amountController.text.isNotEmpty) {
                        addTransaction(userData);
                      }
                    },
                    child: const Text(
                      'Işlemi Gönder',
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
                  const Divider(
                    color: Colors.redAccent,
                    thickness: 5,
                  ),
                  const Text(
                    'Işlem Geçmişi:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userData.currentUser!.email)
                        .collection('Transactions')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                  
                      if (snapshot.hasData) {
                        final transactions = snapshot.data!.docs;
                  
                        return Expanded(
                          child: ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              return ListTile(
                                title: Text(
                                  '${transaction['type']} - ${transaction['category']}',
                                  style: TextStyle(color: (transaction['type']=="Expense"?Colors.red:Colors.green)),
                                ),
                                subtitle: Text(
                                  '${transaction['amount'].toStringAsFixed(2)} ${transaction['currency']}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              );
                            },
                          ),
                        );
                      }
                  
                      return const Text(
                        'No transactions found',
                        style: TextStyle(color: Colors.white),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
