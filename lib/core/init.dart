import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../shared/bridge/lumi_core_bridge.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

/// Application initialization steps that must run before the UI mounts.
///
/// Ensures the on-device DB exists by calling the bridge shim.
/// Also initializes AppwriteService from dart-define env vars for integration tests.
Future<void> initializeApp() async {
  String dbPath;
  
  if (Platform.isAndroid || Platform.isIOS) {
    final docsDir = await getApplicationDocumentsDirectory();
    dbPath = '${docsDir.path}/lumi.db';
  } else {
    // Desktop/Local development behavior
    final buildDir = Directory('${Directory.current.path}/build');
    if (!await buildDir.exists()) {
      await buildDir.create(recursive: true);
    }
    dbPath = '${buildDir.path}/lumi.db';
  }

  // Initialize on-device DB
  await LumiCoreBridge.dbInit(dbPath);

  // Initialize AppwriteService for tests and local dev if dart-defines are provided.
  try {
    final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
    final projectId = const String.fromEnvironment('APPWRITE_PROJECT_ID', defaultValue: '');
    final apiKey = const String.fromEnvironment('APPWRITE_API_KEY', defaultValue: '');

    if (endpoint.isNotEmpty && projectId.isNotEmpty) {
      AppwriteService.instance.init(endpoint: endpoint, projectId: projectId, apiKey: apiKey, createClient: true);
    }
  } catch (_) {
    // Don't fail initialization if Appwrite vars are absent; tests that need Appwrite will surface errors later.
  }
}
