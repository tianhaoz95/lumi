import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// A reusable glassmorphism modal/card container.
/// Use `GlassModal` as the root of modal builders, or call
/// `showGlassModalBottomSheet` to present a bottom sheet with glass styling.
class GlassModal extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const GlassModal({Key? key, required this.child, this.borderRadius, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16.0);

    return Padding(
      padding: padding ?? const EdgeInsets.all(12.0),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: LumiColors.surfaceContainerLowest.withAlpha(179),
              borderRadius: radius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Helper to show a glassmorphism bottom sheet.
Future<T?> showGlassModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (ctx) => SafeArea(
      child: GlassModal(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: builder(ctx),
      ),
    ),
  );
}

/// Helper to show a glassmorphism dialog (centered).
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = Colors.black54,
  Duration transitionDuration = const Duration(milliseconds: 200),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    pageBuilder: (ctx, anim1, anim2) {
      return SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: GlassModal(
              child: builder(ctx),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, secAnim, child) {
      final curved = Curves.easeOut.transform(anim.value);
      return Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - curved) * 20),
          child: child,
        ),
      );
    },
  );
}
