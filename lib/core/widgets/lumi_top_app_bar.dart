import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../colors.dart';

class LumiTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;

  const LumiTopAppBar({Key? key, this.title, this.actions, this.leading, this.elevation = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          color: LumiColors.surfaceContainerLowest.withAlpha(179),
          child: AppBar(
            title: title,
            actions: actions,
            leading: leading,
            backgroundColor: Colors.transparent,
            elevation: elevation,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
