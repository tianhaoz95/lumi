import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../shared/widgets/lumi_button.dart';

/// LumiPrimaryButton: thin wrapper around existing LumiButton to provide a named API.
class LumiPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const LumiPrimaryButton({Key? key, required this.child, this.onPressed, this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LumiButton(
      onPressed: onPressed,
      padding: padding,
      child: child,
    );
  }
}

/// LumiSecondaryButton: glassmorphism-styled secondary button with 40% white overlay and 12px blur.
class LumiSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const LumiSecondaryButton({Key? key, required this.child, this.onPressed, this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24), this.radius = 9999.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.40),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: LumiColors.outlineVariant.withOpacity(0.12)),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(color: Color(0xFF171C1E), fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Preview widget for quick manual checks.
class LumiButtonsPreview extends StatelessWidget {
  const LumiButtonsPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LumiPrimaryButton(
          onPressed: () {},
          child: const Text('Primary'),
        ),
        const SizedBox(height: 12),
        LumiSecondaryButton(
          onPressed: () {},
          child: const Text('Secondary'),
        ),
      ],
    );
  }
}
