import 'package:flutter/material.dart';

class EditTextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const EditTextfield(
      {super.key, required this.hintText, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red)),
              labelText: hintText,
              labelStyle: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
