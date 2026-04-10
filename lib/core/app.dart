import 'package:flutter/material.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumi',
      theme: getLumiTheme(),
      home: const Scaffold(body: Center(child: Text('Lumi Shell'))),
    );
  }
}
