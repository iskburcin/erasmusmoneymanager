import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erasmusmoneymanager/utils/edit_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/profile_detailed_row.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() {
    return FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  bool isEditing = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController eurController = TextEditingController();
  final TextEditingController plnController = TextEditingController();
  final TextEditingController tryController = TextEditingController();
  // Erasmus duration fields
  DateTimeRange? selectedDateRange;
  String? erasmusStartDate;
  String? erasmusEndDate;
  int? duration;
  int? remainedDuration;

  void enableEditing(Map<String, dynamic>? user) {
    setState(() {
      isEditing = true;
      nameController.text = user?['Name'] ?? '';
      surnameController.text = user?['Surname'] ?? '';
      erasmusStartDate = user?['ErasmusStartDate'] ?? '';
      erasmusEndDate = user?['ErasmusEndDate'] ?? '';
      eurController.text =
          double.parse(user?['InitialBalance']['EUR'].toStringAsFixed(2)).toString();
      plnController.text =
          double.parse(user?['InitialBalance']['PLN'].toStringAsFixed(2)).toString();
      tryController.text =
          double.parse(user?['InitialBalance']['TRY'].toStringAsFixed(2)).toString();
    });
    print(duration);
  }

  void saveProfile() async {
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email)
          .update({
        'Name': nameController.text,
        'Surname': surnameController.text,
        'ErasmusStartDate': erasmusStartDate,
        'ErasmusEndDate': erasmusEndDate,
        'InitialBalance': {
          'EUR': double.parse(eurController.text).toStringAsFixed(2),
          'TRY': double.parse(tryController.text).toStringAsFixed(2),
          'PLN': double.parse(plnController.text).toStringAsFixed(2),
        },
      });
      setState(() {
        isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() {
      return FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email)
          .get();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: Colors.black,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final user = await getUserDetails();
                enableEditing(user.data());
              },
            )
        ],
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: isEditing
                  ? buildEditForm(context)
                  : buildProfileView(context, user),
            );
          } else {
            return const Center(child: Text("No data"));
          }
        },
      ),
    );
  }

  Widget buildProfileView(BuildContext context, Map<String, dynamic>? user) {
    DateTime end = DateFormat('yyyy-MM-dd').parse(user?['ErasmusEndDate']);
    DateTime start = DateFormat('yyyy-MM-dd').parse(user?['ErasmusStartDate']);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 64,
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.person, size: 64, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(
          "${user?['Name']} ${user?['Surname']}",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          user?['Email'] ?? '',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        Divider(color: Theme.of(context).colorScheme.onSurface, thickness: 1),
        const SizedBox(height: 5),
        const Text(
          "Erasmus:",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  ProfileDetailRow(
                      label: "Başlangıç",
                      value: user?['ErasmusStartDate'].substring(0, 10)),
                  ProfileDetailRow(
                      label: "Toplam Gün Süresi'",
                      value: (end.difference(start).inDays).toString()),
                ],
              ),
            ),
            const VerticalDivider(
              thickness: 2,
            ),
            Expanded(
              child: Column(
                children: [
                  ProfileDetailRow(
                      label: "Bitiş",
                      value: user?['ErasmusEndDate'].substring(0, 10)),
                  ProfileDetailRow(
                      label: "Kalan Gün Süresi'",
                      value:
                          (end.difference(DateTime.now()).inDays).toString()),
                ],
              ),
            ),
          ],
        ),
        const Divider(),
        ProfileDetailRow(
            label: "Mevcut EUR Hesap Bakiyem",
            value: user?['InitialBalance']['EUR'].toString()),
        ProfileDetailRow(
            label: "Mevcut PLN Hesap Bakiyem",
            value: user?['InitialBalance']['PLN'].toString()),
        ProfileDetailRow(
            label: "Mevcut TRY Hesap Bakiyem",
            value: user?['InitialBalance']['TRY'].toString()),
      ],
    );
  }

  Widget buildEditForm(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
              const CircleAvatar(
                radius: 64,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, size: 64, color: Colors.white),
              ),

              const SizedBox(height: 20),
              EditTextfield(
                controller: nameController,
                hintText: 'Adınız:',
              ),
              const SizedBox(height: 10),
              EditTextfield(
                controller: surnameController,
                hintText: 'Soyadınız:',
              ),
              const SizedBox(height: 10),
              // Erasmus Duration (Date Range Picker)
              ListTile(
                title: Text(selectedDateRange == null
                    ? "Erasmus Süresi: ${erasmusStartDate.toString().substring(0, 10)} - ${erasmusEndDate.toString().substring(0, 10)}"
                    : "Erasmus Süresi: ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2050),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDateRange = picked;
                      erasmusStartDate = picked.start.toString();
                      erasmusEndDate = picked.end.toString();
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              Text(
                  'Duration of Erasmus: ${DateFormat('yyyy-MM-dd').parse(erasmusEndDate.toString()).difference(DateFormat('yyyy-MM-dd').parse(erasmusStartDate.toString())).inDays}'),
              const SizedBox(height: 20),
              EditTextfield(
                controller: eurController,
                hintText: 'Mevcut EUR Hesap Bakiye:',
              ),
              const SizedBox(height: 10),
              EditTextfield(
                controller: plnController,
                hintText: 'Mevcut PLN Hesap Bakiye:',
              ),
              const SizedBox(height: 10),
              EditTextfield(
                controller: tryController,
                hintText: 'Mevcut TRY Hesap Bakiye:',
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: saveProfile,
                icon: const Icon(
                  Icons.save,
                ),
                label: const Text(
                  "Kaydet",
                  style:
                      TextStyle(color: Color.fromARGB(255, 61, 13, 9), fontWeight: FontWeight.bold,fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  iconColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
