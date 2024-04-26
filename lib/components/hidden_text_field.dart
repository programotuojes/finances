import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class HiddenTextField extends StatefulWidget {
  final TextEditingController ctrl;
  final String label;
  final String? errorText;

  const HiddenTextField({
    super.key,
    required this.ctrl,
    required this.label,
    this.errorText,
  });

  @override
  State<HiddenTextField> createState() => _HiddenTextFieldState();
}

class _HiddenTextFieldState extends State<HiddenTextField> {
  bool hide = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.ctrl,
      obscureText: hide,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () {
              setState(() {
                hide = !hide;
              });
            },
            icon: Icon(hide ? Symbols.visibility_rounded : Symbols.visibility_off_rounded),
          ),
        ),
      ),
    );
  }
}
