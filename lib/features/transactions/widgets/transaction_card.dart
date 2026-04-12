import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String vendor;
  final String category;
  final String date;
  final double amount;
  final bool isTagged;
  final VoidCallback? onConfirm;
  final VoidCallback? onEdit;
  final VoidCallback? onDismiss;

  const TransactionCard({
    Key? key,
    required this.vendor,
    required this.category,
    required this.date,
    required this.amount,
    this.isTagged = false,
    this.onConfirm,
    this.onEdit,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0.0;
    final amountColor = isPositive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vendor icon placeholder
            CircleAvatar(
              child: Text(vendor.isNotEmpty ? vendor[0].toUpperCase() : '?'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (isTagged)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.12), // ignore: deprecated_member_use
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'AI',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(amount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: amountColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: onConfirm,
                      tooltip: 'Confirm',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onDismiss,
                      tooltip: 'Dismiss',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amt) {
    final sign = amt < 0 ? '-' : '';
    final absAmt = amt.abs().toStringAsFixed(2);
    return sign + String.fromCharCode(36) + absAmt;
  }
}
