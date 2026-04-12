import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/core/model_router.dart';
import 'package:lumi/shared/chat/chat_service.dart';

void main() {
  test('short casual prompt -> sentinel', () {
    final prompt = 'Hi Lumi, what''s the weather like?';
    expect(ModelRouter.select(prompt), ModelTier.sentinel);
  });

  test('prompt containing analyze my receipts -> auditor', () {
    final prompt = 'Please analyze my receipts and find tax-deductible items.';
    expect(ModelRouter.select(prompt), ModelTier.auditor);
  });

  test('long prompt (>300 chars) -> auditor', () {
    final longPrompt = List.filled(310, 'a').join();
    expect(longPrompt.length, greaterThan(300));
    expect(ModelRouter.select(longPrompt), ModelTier.auditor);
  });
}
