import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// LumiTextField
/// - Filled with `LumiColors.surfaceContainerHigh`
/// - Focused border: 2px `LumiColors.primary` at 40% opacity
/// - Leading icon slot (prefix)
class LumiTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? leading;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool enabled;

  const LumiTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.leading,
    this.onChanged,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        prefixIcon: leading,
        hintText: hintText,
        filled: true,
        fillColor: LumiColors.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumiRadius.defaultRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumiRadius.defaultRadius),
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
