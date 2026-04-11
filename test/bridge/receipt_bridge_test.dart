import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/bridge/lumi_core_bridge.dart';
import 'package:lumi/shared/bridge/receipt.dart';

void main() {
  test('processReceiptImage parses JSON bytes and returns ReceiptData', () async {
    final jsonStr = '''{
      "vendor_name": "Corner Store",
      "total_amount": 12.34,
      "currency": "USD",
      "date": "2026-04-01",
      "line_items": [
        {"description":"Coffee","amount":3.5},
        {"description":"Sandwich","amount":8.84}
      ]
    }''';

    final bytes = Uint8List.fromList(utf8.encode(jsonStr));

    final receipt = await LumiCoreBridge.processReceiptImage(bytes);

    expect(receipt.vendorName, equals('Corner Store'));
    expect(receipt.totalAmount, closeTo(12.34, 0.001));
    expect(receipt.lineItems.length, equals(2));
    expect(receipt.lineItems[0].description, equals('Coffee'));
  });
}
