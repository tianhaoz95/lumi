import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/bridge/lumi_core_bridge.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test('LumiCoreBridge.processReceiptImage uses MethodChannel', () async {
    final channel = const MethodChannel('lumi_core_bridge');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'process_receipt_image') {
        return jsonEncode({
          'vendor_name': 'MethodChannel Store',
          'total_amount': 99.99,
          'currency': 'USD',
          'date': '2026-04-10',
          'line_items': []
        });
      }
      return null;
    });

    final receipt = await LumiCoreBridge.processReceiptImage(Uint8List(0));
    expect(receipt.vendorName, 'MethodChannel Store');
    expect(receipt.totalAmount, 99.99);

    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });
}
