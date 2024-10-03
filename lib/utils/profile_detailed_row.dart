import 'package:flutter/material.dart';

class ProfileDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final DateTime? datevalue;
  final double? numvalue;

  const ProfileDetailRow(
      {super.key,
      required this.label,
      this.value,
      this.numvalue,
      this.datevalue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              (value ?? '${datevalue??numvalue}'),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
