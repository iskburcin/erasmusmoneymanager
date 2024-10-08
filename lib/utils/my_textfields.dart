import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final TextEditingController controller;
  bool? isNumber;

   MyTextfield(
      {super.key,
      this.isNumber,
      required this.labelText,
      required this.obscureText,
      required this.controller});

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
              labelText: labelText,
              labelStyle:
                  TextStyle(color: Colors.grey)),
          obscureText: obscureText,
          keyboardType: (isNumber!) ? TextInputType.number:TextInputType.text,
        ),
      ],
    );
  }
}
