import 'dart:async';

import '../models/transaction_summary.dart';

// Test-time injection point: tests can inject a custom list of recent
// transactions so UI integration tests can verify dynamic updates without
// relying on FRB/native bindings.
List<TransactionSummary>? _injectedTransactions;

/// Test helper to inject transactions for integration tests.
void injectRecentTransactions(List<TransactionSummary> items) {
  _injectedTransactions = items;
}

/// Shim for recent transactions used by the UI when FRB/Rust bindings are not available.
Future<List<TransactionSummary>> fetchRecentTransactions(
    {int limit = 5}) async {
  // If tests injected transactions, return them (respecting limit)
  if (_injectedTransactions != null) {
    await Future.delayed(const Duration(milliseconds: 20));
    return _injectedTransactions!.take(limit).toList();
  }

  await Future.delayed(const Duration(milliseconds: 50));
  // Deterministic development data matching the original mock list
  final items = <TransactionSummary>[
    TransactionSummary(
        id: '1',
        vendor: 'Coffee House',
        category: 'food',
        amount: -6.75,
        date: '2026-04-10',
        isCredit: false),
    TransactionSummary(
        id: '2',
        vendor: 'Office Depot',
        category: 'supplies',
        amount: -45.12,
        date: '2026-04-08',
        isCredit: false),
    TransactionSummary(
        id: '3',
        vendor: 'Mileage Reimbursement',
        category: 'mileage',
        amount: 80.40,
        date: '2026-04-07',
        isCredit: true),
    TransactionSummary(
        id: '4',
        vendor: 'Electric',
        category: 'utilities',
        amount: -120.00,
        date: '2026-04-03',
        isCredit: false),
  ];
  return items.take(limit).toList();
}
