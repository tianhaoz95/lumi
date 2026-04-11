import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/auth/appwrite_service.dart';
import 'package:lumi/features/auth/auth_notifier.dart';

class FakeAccountSuccess {
  Future<void> createEmailPasswordSession({required String email, required String password}) async {
    // simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class FakeAccountFailure {
  Future<void> createEmailPasswordSession({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    throw Exception('Invalid credentials');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AuthNotifier login success sets authenticated state', () async {
    final svc = AppwriteService.instance;
    svc.setAccountForTest(FakeAccountSuccess());

    final notifier = AuthNotifier();
    expect(notifier.state.status, AuthStatus.initial);

    await notifier.login('test@lumi.com', 'password');

    expect(notifier.state.status, AuthStatus.authenticated);
  });

  test('AuthNotifier login failure sets error state', () async {
    final svc = AppwriteService.instance;
    svc.setAccountForTest(FakeAccountFailure());

    final notifier = AuthNotifier();
    expect(notifier.state.status, AuthStatus.initial);

    await notifier.login('test@lumi.com', 'wrong');

    expect(notifier.state.status, AuthStatus.error);
    expect(notifier.state.error, contains('Invalid credentials'));
  });
}
