import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppwriteService init does not throw and ping is safe', () async {
    // Should not throw even if no Appwrite instance is running.
    AppwriteService.instance.init(endpoint: 'http://localhost:12345', projectId: 'lumi-test', apiKey: '');

    // ping should be safe and return a boolean (likely false for local test endpoint).
    final ok = await AppwriteService.instance.ping(timeout: const Duration(seconds: 1));
    expect(ok, isA<bool>());
  });
}
