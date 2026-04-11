import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/bridge/lumi_core_bridge.dart' as lumi_bridge;

void main() {
  test('LumiCoreBridge.processReceiptImage decodes JSON bytes', () async {
    final sampleJson = jsonEncode({
      'vendor_name': 'Corner Store',
      'total_amount': 12.34,
      'currency': 'USD',
      'date': '2026-04-01',
      'line_items': [
        {'description': 'Coffee', 'amount': 3.5},
      ]
    });

    final bytes = Uint8List.fromList(utf8.encode(sampleJson));
    final res = await lumi_bridge.LumiCoreBridge.processReceiptImage(bytes);
    expect(res.vendorName, 'Corner Store');
    expect(res.totalAmount, 12.34);
    expect(res.lineItems.length, 1);
  });
}
