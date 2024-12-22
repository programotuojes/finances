import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class TextFieldListTile extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final EdgeInsets? listTilePadding;
  final Currency? currency;

  const TextFieldListTile({
    super.key,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.listTilePadding,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isMoney = currency != null;

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
        textCapitalization: TextCapitalization.sentences,
        keyboardType: isMoney ? TextInputType.numberWithOptions(decimal: currency!.decimalDigits > 0) : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }
}
