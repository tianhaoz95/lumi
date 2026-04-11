/// Summary bridge shim used by the Flutter UI when the Rust FRB bindings are
/// not yet available. Returns deterministic mock data for development and tests.

import 'dart:async';

Future<Map<String, dynamic>> fetchMonthlySummary() async {
  // In production this should call the Rust core via FRB/MethodChannel.
  // This shim returns a deterministic result that matches the shape the UI expects.
  await Future.delayed(Duration(milliseconds: 50));
  return {
    'total_expenses': 1234.56,
    'total_miles': 120.0,
    'estimated_deduction': 80.40,
  };
}
