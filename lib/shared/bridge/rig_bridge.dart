/// Rig bridge wrapper: typed, FRB-ready API surface for the Flutter UI.
///
/// In production this file should call into the generated FRB bindings which
/// invoke the Rust `get_summary` tool. For now it falls back to the shim
/// implementation in `summary_bridge.dart` so callers can rely on a single
/// typed API.

import 'package:flutter/foundation.dart';
import '../models/financial_summary.dart';
import 'summary_bridge.dart' as shim;
import '../models/transaction_summary.dart';
import 'transactions_bridge.dart' as txshim;

/// Attempts to call the Rust FRB binding. If not available, falls back to
/// the shimbed `fetchMonthlySummary` implementation.
Future<FinancialSummary> fetchMonthlySummary() async {
  // TODO: Replace with FRB call when bindings are available. Example:
  //   return await RigBindings.getSummary("this_month");
  // For now delegate to the shim.
  return shim.fetchMonthlySummary();
}

/// Query recent transactions (typed). In production this should call into
/// the Rust `query_transactions` tool via FRB. For now it delegates to the
/// transactions shim so the UI can be tested end-to-end.
Future<List<TransactionSummary>> queryTransactions({int limit = 5}) async {
  try {
    return await txshim.fetchRecentTransactions(limit: limit);
  } catch (e) {
    // On error, return empty list to avoid crashing the UI.
    return <TransactionSummary>[];
  }
}

