import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

/// LumiAnimations centralizes animation timing and curves used across the app.
/// Use these constants instead of hardcoded durations or curves.
class LumiAnimations {
  LumiAnimations._(); // Prevent instantiation

  static const Duration driftDuration = Duration(milliseconds: 400);
  static const Curve driftCurve = Curves.easeOut;

  static const Duration snapDuration = Duration(milliseconds: 150);
  static const Curve snapCurve = Curves.easeInOut;
}
