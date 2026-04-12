import 'dart:io';

// Simple headless verification script that initializes AppwriteService
// without pulling Flutter. Uses a relative import to the library file.
import '../lib/features/auth/appwrite_service.dart';

Future<void> main(List<String> args) async {
  try {
    // Provide a local endpoint that likely does not respond; the goal is to
    // ensure `init()` completes without throwing.
    AppwriteService.instance.init(endpoint: 'http://localhost:12345', projectId: 'lumi-test', apiKey: '');

    // ping() should return false for a non-running endpoint, but must not throw.
    final ok = await AppwriteService.instance.ping(timeout: const Duration(seconds: 1));
    print('AppwriteService.init() succeeded; ping returned: $ok');
    exit(0);
  } catch (e, st) {
    stderr.writeln('AppwriteService verification failed: $e');
    stderr.writeln(st);
    exit(2);
  }
}
