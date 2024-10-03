import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // To format dates
import '../system/helpers.dart';
import '../utils/my_botton.dart';
import '../utils/my_textfields.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int selectedOption = 1;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  
  // Erasmus duration fields
  DateTimeRange? selectedDateRange;
  DateTime? erasmusStartDate;
  DateTime? erasmusEndDate;
  
  // Currency balance controllers
  final TextEditingController eurBalanceController = TextEditingController();
  final TextEditingController tryBalanceController = TextEditingController();
  final TextEditingController plnBalanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            _title(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(25.0),
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 25),
                  _loginform(),
                  const SizedBox(height: 10),
                  MyBotton(
                    text: "Kaydol",
                    onTap: registerUser,
                  ),
                  const SizedBox(height: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hesabın var mı?",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Giriş Yap",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void registerUser() async {
    // Show loading indicator
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    // Check if passwords match
    if (passwordConfirmController.text != passwordController.text) {
      Navigator.pop(context); // Remove loading indicator
      displayMessageToUser("Şifre eşleşmedi!", context); // Show error
      return;
    }

    // Check if the Erasmus date range and initial balances are set
    if (selectedDateRange == null ||
        eurBalanceController.text.isEmpty ||
        tryBalanceController.text.isEmpty ||
        plnBalanceController.text.isEmpty) {
      Navigator.pop(context); // Remove loading indicator
      displayMessageToUser("Tüm alanları doldurun!", context);
      return;
    }

    try {
      // Create a new user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // Store user data in Firestore
      await createUserDocument(userCredential);

      // Close loading indicator
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading indicator
      displayMessageToUser(e.code, context); // Show error
    }
  }

  Widget _title() {
    return const SizedBox(
      child: Text(
        "E R A S M U S \nM O N E Y\nM A N A G E R",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _loginform() {
    return Column(
      children: [
        // Name and Surname fields
        Row(
          children: [
            Expanded(
              child: MyTextfield(
                hintText: "Adınız",
                obscureText: false,
                controller: nameController,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MyTextfield(
                hintText: "Soyadınız",
                obscureText: false,
                controller: surnameController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Email field
        MyTextfield(
          hintText: "Mail Adresiniz",
          obscureText: false,
          controller: emailController,
        ),
        const SizedBox(height: 10),

        // Password fields
        MyTextfield(
          hintText: "Şifreniz",
          obscureText: true,
          controller: passwordController,
        ),
        const SizedBox(height: 10),
        MyTextfield(
          hintText: "Şifreni Doğrula",
          obscureText: true,
          controller: passwordConfirmController,
        ),
        const SizedBox(height: 20),

        // Erasmus Duration (Date Range Picker)
        ListTile(
          title: Text(selectedDateRange == null
              ? "Erasmus Süresi: Tarih Seçin"
              : "Erasmus Süresi: ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}"),
          trailing: Icon(Icons.calendar_today),
          onTap: () async {
            DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2050),
            );
            if (picked != null) {
              setState(() {
                selectedDateRange = picked;
                erasmusStartDate = picked.start;
                erasmusEndDate = picked.end;
              });
            }
          },
        ),
        const SizedBox(height: 10),

        // Initial balance input fields
        MyTextfield(
          hintText: "Başlangıç Bakiyesi (EUR)",
          obscureText: false,
          controller: eurBalanceController,
        ),
        const SizedBox(height: 10),
        MyTextfield(
          hintText: "Başlangıç Bakiyesi (TRY)",
          obscureText: false,
          controller: tryBalanceController,
        ),
        const SizedBox(height: 10),
        MyTextfield(
          hintText: "Başlangıç Bakiyesi (PLN)",
          obscureText: false,
          controller: plnBalanceController,
        ),
      ],
    );
  }

  // Store the user data in Firestore
  Future<void> createUserDocument(UserCredential userCredential) async {
    if (userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'Email': userCredential.user!.email,
        'Name': nameController.text,
        'Surname': surnameController.text,
        'ErasmusStartDate': erasmusStartDate,
        'ErasmusEndDate': erasmusEndDate,
        'ErasmusRemainingDuration':erasmusEndDate!.difference(DateTime.now()).inDays,
        'InitialBalance': {
          'EUR': double.tryParse(eurBalanceController.text) ?? 0.0,
          'TRY': double.tryParse(tryBalanceController.text) ?? 0.0,
          'PLN': double.tryParse(plnBalanceController.text) ?? 0.0,
        },
      });
    }
  }
}
