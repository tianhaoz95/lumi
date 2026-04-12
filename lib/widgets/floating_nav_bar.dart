import 'dart:ui';

import 'package:flutter/material.dart';

/// FloatingNavBar: a glassmorphism pill nav bar that does not span full width.
/// - Uses backdrop blur
/// - Constrained max width so it doesn't span full screen
/// - Uses design tokens approximated from design system
class FloatingNavBar extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;

  const FloatingNavBar({
    Key? key,
    required this.children,
    this.maxWidth = 720.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFF5FAFC).withOpacity(0.7); // surface at 70%

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF171C1E).withOpacity(0.05),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],

                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
