import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

void main() {
  // Ensure platform bindings are available for any package code that relies on
  // platform channels during test (e.g., path_provider used by Appwrite Client).
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ping returns false when Appwrite is not running on unlikely port', () async {
    final svc = AppwriteService.instance;
    // Use an unlikely port to avoid hitting a local Appwrite instance accidentally.
    svc.init(endpoint: 'http://127.0.0.1:59999/v1', projectId: 'test', createClient: false);
    final ok = await svc.ping(timeout: const Duration(milliseconds: 500));
    expect(ok, isFalse);
  });

  test('restoreSession returns true when account.get succeeds', () async {
    final svc = AppwriteService.instance;

    // Fake Account that returns a non-null user map from get().
    final fakeSuccess = _FakeAccountSuccess();
    svc.setAccountForTest(fakeSuccess);

    final restored = await svc.restoreSession();
    expect(restored, isTrue);

    final user = await svc.getCurrentUser();
    expect(user, isNotNull);
  });

  test('restoreSession returns false when account.get throws', () async {
    final svc = AppwriteService.instance;

    final fakeFail = _FakeAccountFail();
    svc.setAccountForTest(fakeFail);

    final restored = await svc.restoreSession();
    expect(restored, isFalse);

    final user = await svc.getCurrentUser();
    expect(user, isNull);
  });
}

class _FakeAccountSuccess {
  Future<dynamic> get() async {
    return {'id': 'user1', 'name': 'Test User'};
  }
}

class _FakeAccountFail {
  Future<dynamic> get() async {
    throw Exception('No session');
  }
}
