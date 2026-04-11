import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumi',
      home: Scaffold(
        appBar: AppBar(title: const Text('Lumi')),
        body: const Center(child: Text('Lumi App Shell')),
      ),
    );
  }
}
