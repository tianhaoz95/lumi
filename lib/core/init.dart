import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../shared/bridge/lumi_core_bridge.dart';

/// Application initialization steps that must run before the UI mounts.
///
/// Ensures the on-device DB exists by calling the bridge shim.
/// Uses path_provider to find a writable location on mobile devices.
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
  
  await LumiCoreBridge.dbInit(dbPath);
}
