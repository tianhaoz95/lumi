import 'package:flutter/foundation.dart';

class TransactionSummary {
  final String id;
  final String vendor;
  final String category;
  final double amount;
  final String date; // ISO date string
  final bool isCredit;

  TransactionSummary({
    required this.id,
    required this.vendor,
    required this.category,
    required this.amount,
    required this.date,
    required this.isCredit,
  });

  factory TransactionSummary.fromMap(Map<String, dynamic> m) {
    return TransactionSummary(
      id: m['id']?.toString() ?? '',
      vendor: m['vendor']?.toString() ?? '',
      category: m['category']?.toString() ?? '',
      amount: (m['amount'] is num) ? (m['amount'] as num).toDouble() : double.tryParse(m['amount']?.toString() ?? '0') ?? 0.0,
      date: m['date']?.toString() ?? '',
      isCredit: m['isCredit'] == true || m['is_credit'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'vendor': vendor,
        'category': category,
        'amount': amount,
        'date': date,
        'isCredit': isCredit,
      };
}
