import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/core/model_router.dart';

void main() {
  test('short casual prompt -> E2B', () {
    final prompt = 'Hi Lumi, what''s the weather like?';
    expect(ModelRouter.select(prompt), ModelTier.E2B);
  });

  test('prompt containing analyze my receipts -> E4B', () {
    final prompt = 'Please analyze my receipts and find tax-deductible items.';
    expect(ModelRouter.select(prompt), ModelTier.E4B);
  });

  test('long prompt (>300 chars) -> E4B', () {
    final longPrompt = List.filled(310, 'a').join();
    expect(longPrompt.length, greaterThan(300));
    expect(ModelRouter.select(longPrompt), ModelTier.E4B);
  });
}
