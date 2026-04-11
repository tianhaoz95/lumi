import 'dart:io';

import '../shared/bridge/lumi_core_bridge.dart';

/// Application initialization steps that must run before the UI mounts.
///
/// Phase 1: ensure the on-device DB exists by calling the bridge shim.
Future<void> initializeApp() async {
  final buildDir = Directory('${Directory.current.path}/build');
  if (!await buildDir.exists()) {
    await buildDir.create(recursive: true);
  }
  final dbPath = '${buildDir.path}/lumi.db';
  await LumiCoreBridge.dbInit(dbPath);
}
