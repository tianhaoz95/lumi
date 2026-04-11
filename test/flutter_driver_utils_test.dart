import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../integration_test/helpers/flutter_driver_utils.dart';

class _DelayedText extends StatefulWidget {
  final Duration delay;
  final String text;
  const _DelayedText({Key? key, required this.delay, required this.text}) : super(key: key);

  @override
  State<_DelayedText> createState() => _DelayedTextState();
}

class _DelayedTextState extends State<_DelayedText> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _show ? Text(widget.text) : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('pumpUntilFound finds a widget that appears after a delay', (WidgetTester tester) async {
    await tester.pumpWidget(const _DelayedText(delay: Duration(milliseconds: 300), text: 'hello'));

    // The helper should wait until the text appears.
    await pumpUntilFound(tester, find.text('hello'), timeout: const Duration(seconds: 2));

    expect(find.text('hello'), findsOneWidget);
  });
}
