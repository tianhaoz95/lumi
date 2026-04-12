import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/sentinel/notification_service.dart';

void main() {
  test('buildSentinelBody contains count', () {
    final ns = NotificationService();
    final body = ns.buildSentinelBody({
      'untagged_count': 5,
      'missing_days': [],
      'incomplete_mileage': [],
    });
    expect(body.contains('5'), true);
  });

  test('parsePayloadToRoute sentinel -> /dashboard', () {
    final payload = jsonEncode({'type': 'sentinel', 'report': {'untagged_count': 2}});
    final map = NotificationService.parsePayloadToRoute(payload);
    expect(map['route'], '/dashboard');
    expect(map['params'], isNull);
  });

  test('parsePayloadToRoute geofence -> /home with openCamera', () {
    final payload = jsonEncode({'type': 'geofence', 'vendor': 'Cafe', 'lat': 1.0, 'lng': 2.0});
    final map = NotificationService.parsePayloadToRoute(payload);
    expect(map['route'], '/home');
    expect(map['params'], isNotNull);
    expect(map['params']['openCamera'], true);
    expect(map['params']['vendor'], 'Cafe');
  });

  test('notification grouping summary increments and contains lines', () {
    final ns = NotificationService();
    // ensure fresh state
    // create two reports
    final r1 = {'untagged_count': 1, 'missing_days': [], 'incomplete_mileage': []};
    final r2 = {'untagged_count': 2, 'missing_days': ['2026-04-10'], 'incomplete_mileage': []};

    final s1 = ns.processSentinelReport(r1);
    expect(s1['count'], 1);
    expect((s1['lines'] as List).length, 1);
    expect(s1['summaryTitle'], contains('1'));

    final s2 = ns.processSentinelReport(r2);
    expect(s2['count'], 2);
    expect((s2['lines'] as List).length, 2);
    expect(s2['summaryTitle'], contains('2'));
  });
}
