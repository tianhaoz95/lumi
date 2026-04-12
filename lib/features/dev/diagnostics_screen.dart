import 'dart:convert';
import 'package:flutter/material.dart';
import '../../shared/bridge/bridge.dart' as bridge;
import '../../core/widgets/lumi_top_app_bar.dart';
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

  Map<String, dynamic> _receiptDataToJson(ReceiptData data) {
    return {
      'vendorName': data.vendorName,
      'totalAmount': data.totalAmount,
      'currency': data.currency,
      'date': data.date,
      'lineItems': data.lineItems.map((li) => {
        'description': li.description,
        'amount': li.amount,
      }).toList(),
    };
  }

  Future<void> _processSampleReceipt() async {
    final sampleJson = jsonEncode({
      'vendorName': 'Corner Store',
      'totalAmount': 12.34,
      'currency': 'USD',
      'date': '2026-04-01',
      'lineItems': [
        {'description': 'Coffee', 'amount': 3.5},
        {'description': 'Sandwich', 'amount': 8.84}
      ]
    });
    try {
      // Dev diagnostics: parse sample JSON directly instead of relying on native bridge
      final map = json.decode(sampleJson) as Map<String, dynamic>;
      final res = lumi_bridge.ReceiptDataJson.fromJson(map);
      debugPrint('Diagnostics: parsed sample receipt into ReceiptData: ${res.vendorName}');
      setState(() {
        _receiptData = res;
        _receiptJson = jsonEncode(_receiptDataToJson(res));
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
      appBar: LumiTopAppBar(title: const Text('Diagnostics')),
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
                onConfirm: () async {
                  try {
                    final id = await lumi_bridge.LumiCoreBridge.logTransaction(
                      vendor: _receiptData!.vendorName,
                      amount: _receiptData!.totalAmount,
                      currency: _receiptData!.currency,
                      category: 'uncategorized',
                      date: _receiptData!.date,
                      receiptPath: null,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged transaction id: $id')));
                      setState(() {
                        _receiptData = null;
                        _receiptJson = null;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to log transaction: $e')));
                    }
                  }
                },
                onEdit: () async {
                  // show simple edit dialog and on Save call logTransaction with edited values
                  final vendorCtrl = TextEditingController(text: _receiptData!.vendorName);
                  final categoryCtrl = TextEditingController(text: 'uncategorized');
                  final dateCtrl = TextEditingController(text: _receiptData!.date);
                  final amountCtrl = TextEditingController(text: _receiptData!.totalAmount.toString());
                  final currencyCtrl = TextEditingController(text: _receiptData!.currency);

                  final saved = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Edit transaction'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(controller: vendorCtrl, decoration: const InputDecoration(labelText: 'Vendor')),
                            TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category')),
                            TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                            TextField(controller: currencyCtrl, decoration: const InputDecoration(labelText: 'Currency')),
                            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date')),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                        ElevatedButton(
                            onPressed: () async {
                              Navigator.of(ctx).pop(true);
                            },
                            child: const Text('Save')),
                      ],
                    ),
                  );

                  if (saved == true && mounted) {
                    try {
                      final parsedAmount = double.tryParse(amountCtrl.text) ?? _receiptData!.totalAmount;
                      final id = await lumi_bridge.LumiCoreBridge.logTransaction(
                        vendor: vendorCtrl.text,
                        amount: parsedAmount,
                        currency: currencyCtrl.text,
                        category: categoryCtrl.text,
                        date: dateCtrl.text,
                        receiptPath: null,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged transaction id: $id')));
                        setState(() {
                          _receiptData = null;
                          _receiptJson = null;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to log transaction: $e')));
                      }
                    }
                  }
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
