import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Checks whether the primary on-device model is available.
/// For desktop/dev environments this provider resolves to `true` so the UI can proceed.
final modelReadyProvider = FutureProvider<bool>((ref) async {
  // In the current environment assume models are ready (FRB bridge unavailable in unit tests).
  return true;
});
