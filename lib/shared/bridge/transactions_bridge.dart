import 'dart:async';

import '../models/transaction_summary.dart';
import 'package:flutter/material.dart';

/// Shim for recent transactions used by the UI when FRB/Rust bindings are not available.
Future<List<TransactionSummary>> fetchRecentTransactions({int limit = 5}) async {
  await Future.delayed(const Duration(milliseconds: 50));
  // Deterministic development data matching the original mock list
  final items = <TransactionSummary>[
    TransactionSummary(id: '1', vendor: 'Coffee House', category: 'food', amount: -6.75, date: '2026-04-10', isCredit: false),
    TransactionSummary(id: '2', vendor: 'Office Depot', category: 'supplies', amount: -45.12, date: '2026-04-08', isCredit: false),
    TransactionSummary(id: '3', vendor: 'Mileage Reimbursement', category: 'mileage', amount: 80.40, date: '2026-04-07', isCredit: true),
    TransactionSummary(id: '4', vendor: 'Electric', category: 'utilities', amount: -120.00, date: '2026-04-03', isCredit: false),
  ];
  return items.take(limit).toList();
}
