import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

void main() {
  // Ensure platform bindings are available for any package code that relies on
  // platform channels during test (e.g., path_provider used by Appwrite Client).
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ping returns false when Appwrite is not running on unlikely port', () async {
    final svc = AppwriteService.instance;
    // Use an unlikely port to avoid hitting a local Appwrite instance accidentally.
    svc.init(endpoint: 'http://127.0.0.1:59999/v1', projectId: 'test');
    final ok = await svc.ping(timeout: const Duration(milliseconds: 500));
    expect(ok, isFalse);
  });
}
