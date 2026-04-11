import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'appwrite_test_client.dart';

// Integration test helpers for Appwrite and Mailhog interactions.
// These helpers are intended to be used by integration tests that run
// against a locally running Appwrite + Mailhog stack.

/// Polls a Mailhog-like HTTP API for an email sent to [to].
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
              // ignore malformed items
            }
          }
        }
      }
    } catch (e) {
      // treat network errors as transient
    }
    await Future.delayed(pollInterval);
  }

  httpClient.close(force: true);
  throw TimeoutException('Timed out waiting for email to $to');
}

/// Creates a test session using Appwrite SDK environment variables.
Future<void> createTestSession() async {
  final email = const String.fromEnvironment('TEST_USER_EMAIL', defaultValue: '');
  final password = const String.fromEnvironment('TEST_USER_PASSWORD', defaultValue: '');

  if (email.isEmpty || password.isEmpty) {
    throw StateError('Appwrite environment variables not set. Skipping createTestSession.');
  }

  final client = buildTestClient();
  final account = Account(client);
  await account.createEmailPasswordSession(email: email, password: password);
}

/// Deletes all sessions for the current test user.
Future<void> clearTestSessions() async {
  final email = const String.fromEnvironment('TEST_USER_EMAIL', defaultValue: '');
  final password = const String.fromEnvironment('TEST_USER_PASSWORD', defaultValue: '');

  if (email.isEmpty || password.isEmpty) {
    return; // Don't fail if env not set, just skip
  }

  final client = buildTestClient();
  final account = Account(client);
  try {
    await account.createEmailPasswordSession(email: email, password: password);
    await account.deleteSessions();
  } catch (e) {
    // If we can't login, sessions are likely already clear or user doesn't exist yet
  }
}
