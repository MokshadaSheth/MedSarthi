import 'package:flutter/material.dart';

class FormContainerWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? icon;
  final bool isPassword;
  final TextInputType? inputType;

  const FormContainerWidget({
    Key? key,
    this.controller,
    required this.hintText,
    this.icon,
    this.isPassword = false,
    this.inputType,
  }) : super(key: key);

  @override
  State<FormContainerWidget> createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.inputType,
        obscureText: widget.isPassword ? _obscureText : false,
        decoration: InputDecoration(
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          hintText: widget.hintText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.black54),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
        ),
      ),
    );
  }
}
