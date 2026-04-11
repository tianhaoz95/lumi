import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/core/model_router.dart';
import 'package:lumi/shared/chat/chat_service.dart' show ModelTier;

void main() {
  test('ModelRouter.select returns sentinel for short casual prompts', () {
    final tier = ModelRouter.select('Hello there! How are you?');
    expect(tier, equals(ModelTier.sentinel));
  });

  test('ModelRouter.select returns auditor for prompts containing keywords', () {
    final tier = ModelRouter.select('Please analyze my receipts and find deductions');
    expect(tier, equals(ModelTier.auditor));
  });

  test('ModelRouter.select returns auditor for long prompts (>300 chars)', () {
    final longPrompt = List.filled(310, 'a').join();
    final tier = ModelRouter.select(longPrompt);
    expect(tier, equals(ModelTier.auditor));
  });
}
