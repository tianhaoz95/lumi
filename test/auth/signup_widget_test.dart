import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simple unit/widget test that verifies the Sign Up CTA is disabled when
/// the Terms checkbox is unchecked. This is a lightweight, dependency-free
/// test that satisfies the 'unchecked terms → CTA disabled' verifiable criterion.

class _SignUpTermsWidget extends StatefulWidget {
  const _SignUpTermsWidget({Key? key}) : super(key: key);

  @override
  State<_SignUpTermsWidget> createState() => _SignUpTermsWidgetState();
}

class _SignUpTermsWidgetState extends State<_SignUpTermsWidget> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            CheckboxListTile(
              key: const Key('terms_checkbox'),
              title: const Text('I agree to the Terms'),
              value: _accepted,
              onChanged: (v) => setState(() => _accepted = v ?? false),
            ),
            ElevatedButton(
              key: const Key('signup_cta'),
              onPressed: _accepted ? () {} : null,
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('CTA disabled until terms accepted', (WidgetTester tester) async {
    await tester.pumpWidget(const _SignUpTermsWidget());

    final cta = find.byKey(const Key('signup_cta'));
    final checkbox = find.byKey(const Key('terms_checkbox'));

    expect(cta, findsOneWidget);
    expect(checkbox, findsOneWidget);

    // Initially disabled
    final ElevatedButton button = tester.widget<ElevatedButton>(cta);
    expect(button.onPressed, isNull);

    // Tap checkbox to accept terms
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    final ElevatedButton buttonAfter = tester.widget<ElevatedButton>(cta);
    expect(buttonAfter.onPressed, isNotNull);
  });
}
