import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:med_sarathi/themes/theme_provider.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final int maxLines;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.maxLines = 1,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword,
      maxLines: maxLines,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onBackground,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }
}