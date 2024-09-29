import 'package:finances/utils/amount_input_formatter.dart';
import 'package:flutter/material.dart';

class TextFieldListTile extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final EdgeInsets? listTilePadding;
  final bool money;

  const TextFieldListTile({
    super.key,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.listTilePadding,
    this.money = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 0,
      contentPadding: listTilePadding,
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
