import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../shared/models/financial_summary.dart';
import '../../transactions/widgets/transaction_card.dart';
import '../../../shared/models/transaction_summary.dart';

class InsightCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const InsightCard._(this.data, {Key? key}) : super(key: key);

  factory InsightCard.fromMap(Map<String, dynamic> m) => InsightCard._(m);

  @override
  Widget build(BuildContext context) {
    final type = data['insight_type']?.toString() ?? '';
    if (type == 'summary' && data.containsKey('summary')) {
      final summaryMap = Map<String, dynamic>.from(data['summary'] as Map);
      final summary = FinancialSummary.fromJson(summaryMap);
      return _buildSummary(context, summary);
    }

    if (type == 'transactions' && data.containsKey('transactions')) {
      final list = (data['transactions'] as List).map((e) => TransactionSummary.fromMap(Map<String, dynamic>.from(e as Map))).toList();
      return _buildTransactionList(context, list);
    }

    // Fallback: pretty-print JSON
    return _buildJsonFallback(context, data);
  }

  Widget _buildSummary(BuildContext context, FinancialSummary s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Summary', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total expenses', style: Theme.of(context).textTheme.bodyMedium),
            Text('\$${s.totalExpenses.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total miles', style: Theme.of(context).textTheme.bodySmall),
            Text('${s.totalMiles.toStringAsFixed(1)} mi', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Estimated deduction', style: Theme.of(context).textTheme.bodySmall),
            Text('\$${s.estimatedDeduction.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionList(BuildContext context, List<TransactionSummary> items) {
    if (items.isEmpty) return const Text('No transactions');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transactions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Column(
          children: items
              .map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TransactionCard(
                      vendor: t.vendor,
                      category: t.category,
                      date: t.date,
                      amount: t.amount,
                      isTagged: false,
                      onConfirm: () {},
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildJsonFallback(BuildContext context, Map<String, dynamic> m) {
    final pretty = const JsonEncoder.withIndent('  ').convert(m);
    return Text(pretty, style: const TextStyle(fontFamily: 'monospace'));
  }
}
