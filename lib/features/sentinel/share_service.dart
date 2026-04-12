import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import '../../shared/bridge/lumi_core_bridge.dart';
import 'notification_service.dart';

/// Service to handle OS Share intents and route shared images to the
/// Rust `process_receipt_image` pipeline via `LumiCoreBridge`.
///
/// This implementation uses platform channels named 'lumi_share' and
/// 'lumi_share_stream'. Native platform code (Android/iOS) may opt to
/// forward ACTION_SEND events to these channels. If no native wiring is
/// present, the service is a no-op (safe in tests).
class ShareService {
  static final ShareService _instance = ShareService._();
  ShareService._();
  factory ShareService() => _instance;

  final MethodChannel _channel = const MethodChannel('lumi_share');
  final EventChannel _stream = const EventChannel('lumi_share_stream');

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Cold-start: ask native layer for any initial shared media paths
    try {
      final List<dynamic>? initial = await _channel.invokeMethod<List<dynamic>>('getInitialMedia');
      if (initial != null && initial.isNotEmpty) {
        final paths = initial.map((e) => e.toString()).toList();
        await _handleSharedPaths(paths);
      }
    } catch (e) {
      stderr.writeln('[ShareService] getInitialMedia failed: $e');
    }

    // Runtime stream of shared media paths from native
    try {
      _stream.receiveBroadcastStream().listen((dynamic event) {
        if (event is List) {
          final paths = event.map((e) => e.toString()).toList();
          _handleSharedPaths(paths);
        } else if (event is String) {
          _handleSharedPaths([event]);
        }
      }, onError: (e) {
        stderr.writeln('[ShareService] share stream error: $e');
      });
    } catch (e) {
      stderr.writeln('[ShareService] failed to subscribe to share stream: $e');
    }
  }

  Future<void> _handleSharedPaths(List<String> paths) async {
    for (final path in paths) {
      try {
        final bytes = await File(path).readAsBytes();
        final receipt = await LumiCoreBridge.processReceiptImage(bytes);

        // Notify user that receipt was parsed; keep grouped under sentinel alerts
        try {
          await NotificationService().showSentinelAlert({
            'untagged_count': 0,
            'missing_days': [],
            'incomplete_mileage': [],
            'receipt_parsed': true,
            'vendor': receipt.vendorName,
            'amount': receipt.totalAmount,
          });
        } catch (e) {
          stderr.writeln('[ShareService] Notification failed: $e');
        }

        // Perform lightweight subscription detection on the parsed receipt text and notify if found.
        try {
          final combinedText = StringBuffer()..write(receipt.vendorName ?? '');
          if (receipt.lineItems != null && receipt.lineItems.isNotEmpty) {
            combinedText.write(' ');
            combinedText.writeAll(receipt.lineItems.map((li) => li.description), ' ');
          }
          combinedText.write(' ${receipt.totalAmount}');
          final sub = _detectSubscriptionFromText(combinedText.toString());
          if (sub != null) {
            await NotificationService().showSubscriptionAlert(sub['service'] as String, amount: sub['amount'] as double?);
          }
        } catch (e) {
          stderr.writeln('[ShareService] subscription detection failed: $e');
        }
      } catch (e) {
        stderr.writeln('[ShareService] failed to process shared media $path: $e');
      }
    }
  }
}

/// Lightweight Dart-side subscription detection used by ShareService as a secondary check.
Map<String, dynamic>? _detectSubscriptionFromText(String text) {
  final lower = text.toLowerCase();
  final keywords = ['subscription', 'monthly', 'annual', 'annually', 'renews', 'renew', 'billed every', 'recurring', 'auto-renew', 'auto renew'];
  if (!keywords.any((k) => lower.contains(k))) return null;

  // amount like $15.99 or 15.99
  final amtRe = RegExp(r"\$?(\d{1,3}(?:[.,]\d{2})?)");
  double? amount;
  final amtMatch = amtRe.firstMatch(text);
  if (amtMatch != null) {
    final s = amtMatch.group(1)!.replaceAll(',', '.');
    amount = double.tryParse(s);
  }

  // service name: capitalized word sequence before keywords
  final serviceRe = RegExp(r"([A-Z][A-Za-z0-9&\- ]{1,40})\s+(?:subscription|renew|renews|billed|recurring|auto-renew)", multiLine: true);
  String service = 'Unknown';
  final svcMatch = serviceRe.firstMatch(text);
  if (svcMatch != null) {
    service = svcMatch.group(1)!.trim();
  } else {
    // fallback: first capitalized token sequence
    final capRe = RegExp(r"([A-Z][a-zA-Z0-9&]{1,30}(?:\s+[A-Z][a-zA-Z0-9&]{1,30}){0,2})");
    final cap = capRe.firstMatch(text);
    if (cap != null) service = cap.group(1)!.trim();
  }

  // conservative: if nothing obvious, return null
  if (service == 'Unknown' && (amount == null || amount == 0.0)) return null;

  return {'service': service, 'amount': amount};
}
