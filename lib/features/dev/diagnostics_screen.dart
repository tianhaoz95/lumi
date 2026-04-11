import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../shared/bridge/bridge.dart' as bridge;
import '../../shared/bridge/lumi_core_bridge.dart' as lumi_bridge;

// Dev-only diagnostics screen that shows ping() result from Rust core.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  String _ping = 'loading...';
  String? _receiptJson;

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
      final bytes = Uint8List.fromList(utf8.encode(sampleJson));
      debugPrint('Diagnostics: calling processReceiptImage with ${bytes.length} bytes');
      final res = await lumi_bridge.LumiCoreBridge.processReceiptImage(bytes);
      debugPrint('Diagnostics: processReceiptImage returned: ${res.toJson()}');
      setState(() => _receiptJson = jsonEncode(res.toJson()));
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
            if (_receiptJson != null) ...[
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
