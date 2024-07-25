import 'package:finances/utils/amount_input_formatter.dart';
import 'package:flutter/material.dart';

class TextFieldListTile extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final bool morePadding;
  final bool money;

  const TextFieldListTile({
    super.key,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.morePadding = false,
    this.money = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 0,
      contentPadding: morePadding ? const EdgeInsets.symmetric(horizontal: 24) : null,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon),
      ),
      title: TextField(
        controller: controller,
        keyboardType: money ? const TextInputType.numberWithOptions(decimal: true) : null,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: money ? amountFormatter : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }
}
