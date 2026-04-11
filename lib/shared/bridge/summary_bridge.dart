/// Summary bridge shim used by the Flutter UI when the Rust FRB bindings are
/// not yet available. Returns deterministic mock data for development and tests.

import 'dart:async';
import '../models/financial_summary.dart';

Future<FinancialSummary> fetchMonthlySummary() async {
  // In production this should call the Rust core via FRB/MethodChannel/FRB-generated bindings.
  // This shim returns a deterministic result that matches the shape the UI expects.
  await Future.delayed(Duration(milliseconds: 50));
  return FinancialSummary(
    totalExpenses: 1234.56,
    totalMiles: 120.0,
    estimatedDeduction: 80.40,
  );
}
