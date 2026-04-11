/// Rig bridge wrapper: typed, FRB-ready API surface for the Flutter UI.
///
/// In production this file should call into the generated FRB bindings which
/// invoke the Rust `get_summary` tool. For now it falls back to the shim
/// implementation in `summary_bridge.dart` so callers can rely on a single
/// typed API.

import 'package:flutter/foundation.dart';
import '../models/financial_summary.dart';
import 'summary_bridge.dart' as shim;

/// Attempts to call the Rust FRB binding. If not available, falls back to
/// the shimbed `fetchMonthlySummary` implementation.
Future<FinancialSummary> fetchMonthlySummary() async {
  // TODO: Replace with FRB call when bindings are available. Example:
  //   return await RigBindings.getSummary("this_month");
  // For now delegate to the shim.
  return shim.fetchMonthlySummary();
}

/// Placeholder for future query_transactions binding. Returns empty list
/// until FRB/Rust implementation is available.
Future<List<Map<String, dynamic>>> queryTransactions({int limit = 5}) async {
  // TODO: wire to Rust `query_transactions` tool via FRB.
  return <Map<String, dynamic>>[];
}
