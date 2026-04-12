import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/sentinel/notification_service.dart';

void main() {
  test('Subscription notification body contains service name', () {
    final body = NotificationService().buildSubscriptionBody('Netflix', amount: 15.99);
    expect(body.contains('Netflix'), isTrue);
    expect(body.contains('15.99'), isTrue);
  });
}
