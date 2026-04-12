import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumi/shared/widgets/glass_modal.dart';

void main() {
  testWidgets('GlassModal shows BackdropFilter and content', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                await showGlassModalBottomSheet<String>(
                  context: context,
                  builder: (ctx) => const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('ModalContent', key: Key('modal_text')),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        );
      }),
    ));

    // Open the modal
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Modal content should be visible
    expect(find.byKey(const Key('modal_text')), findsOneWidget);
    // BackdropFilter should be in the widget tree
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
