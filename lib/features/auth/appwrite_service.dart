// AppwriteService singleton — Phase 1 -> Phase 3 implementation
// Provides a thin on-device wrapper around the Appwrite Dart SDK and a
// convenience health `ping()` method that does not require Appwrite to be
// initialized.

import 'dart:io';

import 'package:appwrite/appwrite.dart';

class AppwriteService {
  AppwriteService._private();

  static final AppwriteService instance = AppwriteService._private();

  Client? _client;
  // Use dynamic for _account so tests can inject a fake account implementation.
  dynamic _account;
  String _endpoint = 'http://localhost/v1';
  String _projectId = 'lumi-dev';

  /// Initialize the Appwrite client. Call once at app startup (after reading
  /// environment config). `apiKey` is optional and only required for server-side
  /// operations in CI.
  void init({String? endpoint, String? projectId, String? apiKey}) {
    _endpoint = endpoint ?? _endpoint;
    _projectId = projectId ?? _projectId;

    _client = Client()
        .setEndpoint(_endpoint)
        .setProject(_projectId);

    // Note: Appwrite Dart SDK's client does not expose a setKey() method in
    // the Flutter/browser client. Server-side API keys are not required for the
    // client's typical usage in the app. If future CI needs server keys, inject
    // them into a server-side wrapper.

    _account = Account(_client!);
  }

  /// Test helper: replace the underlying Account instance with a fake.
  /// Only intended for unit tests.
  @pragma('vm:entry-point')
  void setAccountForTest(dynamic account) {
    _account = account;
  }

  /// Access the underlying Appwrite Client. Throws if `init()` was not called.
  Client get client {
    if (_client == null) {
      throw StateError('AppwriteService not initialized. Call init() first.');
    }
    return _client!;
  }

  /// Access the Appwrite Account API.
  dynamic get account {
    if (_account == null) {
      throw StateError('AppwriteService not initialized. Call init() first.');
    }
    return _account;
  }

  /// Lightweight health check against the Appwrite HTTP health endpoint.
  /// Returns `true` iff the endpoint responded with HTTP 200 within [timeout].
  /// This does not require the Appwrite Dart SDK to be functional and is safe
  /// to call during CI/dev machine checks.
  Future<bool> ping({Duration timeout = const Duration(seconds: 2)}) async {
    try {
      final uri = Uri.parse('$_endpoint/health');
      final httpClient = HttpClient();
      httpClient.connectionTimeout = timeout;
      final request = await httpClient.getUrl(uri);
      final response = await request.close().timeout(timeout);
      final ok = response.statusCode == 200;
      httpClient.close();
      return ok;
    } catch (_) {
      return false;
    }
  }

  /// Attempt to sign in with email+password using Appwrite Account API.
  /// Throws an exception on failure. Tests can inject a fake account that
  /// implements `createSession({required String email, required String password})`.
  Future<void> login(String email, String password) async {
    if (_account == null) throw StateError('AppwriteService not initialized.');
    try {
      // Appwrite Dart SDK exposes createSession(email: password:)
      await _account.createSession(email: email, password: password);
    } catch (e) {
      // Re-throw so callers can surface errors to UI/tests.
      rethrow;
    }
  }

  /// Sign out by deleting the current session if possible.
  Future<void> logout() async {
    if (_account == null) return;
    try {
      // Not all appwrite SDK versions support deleteSession current; attempt and ignore failures.
      if (_account.deleteSession != null) {
        await _account.deleteSession('current');
      }
    } catch (_) {
      // ignore
    }
  }
}
