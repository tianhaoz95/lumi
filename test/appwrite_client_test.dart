import 'package:flutter_test/flutter_test.dart';

import '../integration_test/helpers/appwrite_test_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildTestClient returns a Client instance', () {
    final client = buildTestClient();
    expect(client, isNotNull);
  });
}
