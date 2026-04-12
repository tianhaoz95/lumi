/// Rig bridge wrapper: typed, FRB-ready API surface for the Flutter UI.
///
/// In production this file should call into the generated FRB bindings which
/// invoke the Rust `get_summary` tool. For now it falls back to the shim
/// implementation in `summary_bridge.dart` so callers can rely on a single
/// typed API.

import '../models/financial_summary.dart';
import 'summary_bridge.dart' as shim;
import '../models/transaction_summary.dart' as app_models;
import 'transactions_bridge.dart' as txshim;

/// Attempts to call the Rust FRB binding. If not available, falls back to
/// the shimbed `fetchMonthlySummary` implementation.
import 'lumi_core_bridge.dart' as frb;

Future<FinancialSummary> fetchMonthlySummary() async {
  try {
    final res = await frb.LumiCoreBridge.getSummary('this_month');
    // Convert FRB typed model to the app's FinancialSummary model
    return FinancialSummary(
      totalExpenses: res.totalExpenses,
      totalMiles: res.totalMiles,
      estimatedDeduction: res.estimatedDeduction,
    );
  } catch (e) {
    // FRB/native binding not available — fall back to shim for development and tests
    return shim.fetchMonthlySummary();
  }
}

/// Query recent transactions (typed). In production this should call into
/// the Rust `query_transactions` tool via FRB. For now it delegates to the
/// transactions shim so the UI can be tested end-to-end.
Future<List<app_models.TransactionSummary>> queryTransactions({int limit = 5}) async {
  try {
    // Try native FRB binding first
    final res = await frb.LumiCoreBridge.queryTransactions(limit: limit);
    return res.map((e) => app_models.TransactionSummary(
      id: e.id,
      vendor: e.vendor ?? 'Unknown',
      amount: e.amount,
      category: e.category ?? 'uncategorized',
      date: DateTime.fromMillisecondsSinceEpoch(e.timestamp * 1000).toIso8601String(),
      isCredit: e.isTagged,
    )).toList();
  } catch (e) {
    // FRB/native binding not available — fall back to shim for development and tests
    try {
      return await txshim.fetchRecentTransactions(limit: limit);
    } catch (e2) {
      return <app_models.TransactionSummary>[];
    }
  }
}
