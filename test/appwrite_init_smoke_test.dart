import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppwriteService init and setAccountForTest do not throw', () async {
    final svc = AppwriteService.instance;

    // Initialize with createClient = false so tests do not attempt network connections.
    svc.init(endpoint: 'http://127.0.0.1:59999/v1', projectId: 'test', createClient: false);

    // Should not throw when pinging an unlikely port (returns false but is safe).
    final ok = await svc.ping(timeout: const Duration(milliseconds: 500));
    expect(ok, isFalse);

    // Inject a fake account and assert restoreSession handles it.
    final fake = _FakeAccount();
    svc.setAccountForTest(fake);

    final restored = await svc.restoreSession();
    expect(restored, isTrue);

    final user = await svc.getCurrentUser();
    expect(user, isNotNull);
  });
}

class _FakeAccount {
  Future<dynamic> get() async => {'id': 'fake-user'};
}
