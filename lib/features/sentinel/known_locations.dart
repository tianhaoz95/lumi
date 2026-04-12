import 'package:flutter/material.dart';
import '../../shared/bridge/lumi_core_bridge.dart';
import '../../core/widgets/lumi_top_app_bar.dart';

class KnownLocationsScreen extends StatefulWidget {
  const KnownLocationsScreen({Key? key}) : super(key: key);

  @override
  State<KnownLocationsScreen> createState() => _KnownLocationsScreenState();
}

class _KnownLocationsScreenState extends State<KnownLocationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _latCtl = TextEditingController();
  final _lngCtl = TextEditingController();
  final _radiusCtl = TextEditingController(text: '150');
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _latCtl.dispose();
    _lngCtl.dispose();
    _radiusCtl.dispose();
    super.dispose();
  }

  Future<void> _onAdd() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtl.text.trim();
    final lat = double.tryParse(_latCtl.text.trim()) ?? 0.0;
    final lng = double.tryParse(_lngCtl.text.trim()) ?? 0.0;
    setState(() => _submitting = true);
    try {
      final id = await LumiCoreBridge.addVendorFence(name, lat, lng);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added fence: $id')));
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add fence: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LumiTopAppBar(title: const Text('Known Locations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Vendor name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _latCtl,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (double.tryParse(v ?? '') == null) ? 'Invalid latitude' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngCtl,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (double.tryParse(v ?? '') == null) ? 'Invalid longitude' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _radiusCtl,
                decoration: const InputDecoration(labelText: 'Radius (meters)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (double.tryParse(v ?? '') == null) ? 'Invalid radius' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _onAdd,
                child: _submitting ? const CircularProgressIndicator() : const Text('Add Fence'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
