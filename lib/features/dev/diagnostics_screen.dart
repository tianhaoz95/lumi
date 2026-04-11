import 'package:flutter/material.dart';
import '../../shared/bridge/bridge.dart' as bridge;

// Dev-only diagnostics screen that shows ping() result from Rust core.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  String _ping = 'loading...';

  @override
  void initState() {
    super.initState();
    _callPing();
  }

  Future<void> _callPing() async {
    try {
      final res = await bridge.ping();
      setState(() => _ping = res);
    } catch (e) {
      setState(() => _ping = 'error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rust ping() result:'),
            const SizedBox(height: 12),
            Text(_ping, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _callPing,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
