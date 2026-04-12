import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../shared/bridge/bridge.dart' as bridge;
import '../../shared/bridge/lumi_core_bridge.dart' as lumi_bridge;
import '../../shared/bridge/receipt.dart';
import '../transactions/widgets/transaction_card.dart';

// Dev-only diagnostics screen that shows ping() result from Rust core.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  String _ping = 'loading...';
  String? _receiptJson;
  ReceiptData? _receiptData;

  @override
  void initState() {
    super.initState();
    _callPing();
  }

  Future<void> _callPing() async {
    try {
      final res = await bridge.ping();
      setState(() => _ping = res);
    } catch (e) {
      setState(() => _ping = 'error: $e');
    }
  }

  Future<void> _processSampleReceipt() async {
    final sampleJson = jsonEncode({
      'vendor_name': 'Corner Store',
      'total_amount': 12.34,
      'currency': 'USD',
      'date': '2026-04-01',
      'line_items': [
        {'description': 'Coffee', 'amount': 3.5},
        {'description': 'Sandwich', 'amount': 8.84}
      ]
    });
    try {
      // Dev diagnostics: parse sample JSON directly instead of relying on native bridge
      final map = json.decode(sampleJson) as Map<String, dynamic>;
      final res = ReceiptData.fromJson(map);
      debugPrint('Diagnostics: parsed sample receipt into ReceiptData: ${res.toJson()}');
      setState(() {
        _receiptData = res;
        _receiptJson = jsonEncode(res.toJson());
      });
      debugPrint('Diagnostics: _receiptData set to ${res.vendorName}');
    } catch (e) {
      debugPrint('Diagnostics: processReceiptImage error: $e');
      setState(() => _receiptJson = 'error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rust ping() result:'),
            const SizedBox(height: 12),
            Text(_ping, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _callPing, child: const Text('Refresh')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processSampleReceipt,
              child: const Text('Process Sample Receipt (dev)'),
            ),
            const SizedBox(height: 12),
            if (_receiptData != null) ...[
              TransactionCard(
                vendor: _receiptData!.vendorName,
                category: 'uncategorized',
                date: _receiptData!.date,
                amount: -_receiptData!.totalAmount,
                isTagged: true,
                onConfirm: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirmed (not yet persisted)')));
                },
                onEdit: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit not implemented')));
                },
                onDismiss: () {
                  setState(() {
                    _receiptData = null;
                    _receiptJson = null;
                  });
                },
              ),
            ] else if (_receiptJson != null) ...[
              const Text('Receipt JSON:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                width: 600,
                child: Text(_receiptJson!, style: const TextStyle(fontFamily: 'monospace')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
