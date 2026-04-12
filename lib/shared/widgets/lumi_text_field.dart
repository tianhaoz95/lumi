import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/lumi_animations.dart';

/// LumiTextField
/// - Filled with `LumiColors.surfaceContainerHigh`
/// - Focused border: 2px `LumiColors.primary` at 40% opacity
/// - Leading icon slot (prefix)
// Adds drifting ease-out animation on focus for input fields.
class LumiTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? leading;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool enabled;
  final FocusNode? focusNode;

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
    this.focusNode,
  }) : super(key: key);

  @override
  _LumiTextFieldState createState() => _LumiTextFieldState();
}

class _LumiTextFieldState extends State<LumiTextField> {
  late FocusNode _focusNode;
  bool _focused = false;
  bool _ownFocusNode = false;

  static const Duration _animDuration = LumiAnimations.driftDuration;
  static const Curve _animCurve = LumiAnimations.driftCurve;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      transform: _focused ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: LumiColors.onSurface.withAlpha(((_focused ? 0.06 : 0.02) * 255).round()),
            blurRadius: _focused ? 18 : 8,
            offset: Offset(0, _focused ? 8 : 4),
          ),
        ],
      ),
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        onChanged: widget.onChanged,
        obscureText: widget.obscureText,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        enabled: widget.enabled,
        decoration: InputDecoration(
          prefixIcon: widget.leading,
          hintText: widget.hintText,
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
      ),
    );
  }
}
