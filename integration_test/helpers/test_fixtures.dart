import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Integration test helpers for Appwrite and Mailhog interactions.
// These helpers are intended to be used by integration tests that run
// against a locally running Appwrite + Mailhog stack. If the required
// environment variables are not provided, Appwrite-related helpers will
// throw a StateError. The mailhog helper is testable locally.

/// Polls a Mailhog-like HTTP API for an email sent to [to].
///
/// By default polls http://localhost:8025/api/v2/messages. The optional
/// [mailhogUrl] allows overriding for tests. Returns the message body
/// (raw string) of the first matched message. Throws [TimeoutException]
/// if not found within [timeout].
Future<String> waitForEmail(
  String to, {
  Duration timeout = const Duration(seconds: 10),
  Duration pollInterval = const Duration(milliseconds: 500),
  String mailhogUrl = 'http://localhost:8025',
}) async {
  final uri = Uri.parse('$mailhogUrl/api/v2/messages');
  final end = DateTime.now().add(timeout);
  final httpClient = HttpClient();

  while (DateTime.now().isBefore(end)) {
    try {
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        final decoded = json.decode(body);
        // Expecting a Mailhog-like structure: {"items": [ { "Content": { "Headers": { "To": ["..."] }, "Body": "..." } }, ... ] }
        if (decoded is Map && decoded['items'] is List) {
          for (final item in decoded['items']) {
            try {
              final content = item['Content'];
              final headers = content['Headers'];
              final toList = headers['To'];
              if (toList is List && toList.contains(to)) {
                final messageBody = content['Body'];
                httpClient.close(force: true);
                return messageBody is String ? messageBody : json.encode(messageBody);
              }
            } catch (e) {
              // ignore malformed items and continue
            }
          }
        }
      }
    } catch (e) {
      // treat network errors as transient while polling
    }

    await Future.delayed(pollInterval);
  }

  httpClient.close(force: true);
  throw TimeoutException('Timed out waiting for email to $to');
}

/// Creates a test session using Appwrite SDK environment variables.
///
/// This function requires the following dart-define variables to be set:
/// - APPWRITE_ENDPOINT
/// - APPWRITE_PROJECT_ID
/// - TEST_USER_EMAIL
/// - TEST_USER_PASSWORD
///
/// If any are missing, a [StateError] is thrown. This helper intentionally
/// avoids calling Appwrite during unit tests unless the env is provided.
Future<void> createTestSession() async {
  final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
  final projectId = const String.fromEnvironment('APPWRITE_PROJECT_ID', defaultValue: '');
  final email = const String.fromEnvironment('TEST_USER_EMAIL', defaultValue: '');
  final password = const String.fromEnvironment('TEST_USER_PASSWORD', defaultValue: '');

  if (endpoint.isEmpty || projectId.isEmpty || email.isEmpty || password.isEmpty) {
    throw StateError('Appwrite environment variables not set. Skipping createTestSession.');
  }

  // Appwrite helpers are intentionally not implemented for unit test runs.
  // Integration tests that need Appwrite should run with the proper .env.test
  // and a running Appwrite instance; implement createTestSession() there.
  throw StateError('createTestSession is not implemented in unit-test mode.');

  // Actual implementation would initialize Client and Account and create a session.
  // Leaving a TODO here because integration tests that actually call Appwrite must have
  // a running Appwrite instance and proper dart-define values.
  // TODO: implement createTestSession using Appwrite Account.createEmailSession
}

/// Deletes all sessions for the current test user.
///
/// Like [createTestSession], this requires Appwrite dart-define env vars.
Future<void> clearTestSessions() async {
  final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
  final projectId = const String.fromEnvironment('APPWRITE_PROJECT_ID', defaultValue: '');
  final email = const String.fromEnvironment('TEST_USER_EMAIL', defaultValue: '');
  final password = const String.fromEnvironment('TEST_USER_PASSWORD', defaultValue: '');

  if (endpoint.isEmpty || projectId.isEmpty || email.isEmpty || password.isEmpty) {
    throw StateError('Appwrite environment variables not set. Skipping clearTestSessions.');
  }

  // TODO: implement using Appwrite Account.deleteSessions()
}
