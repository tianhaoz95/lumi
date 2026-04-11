import '../shared/chat/chat_service.dart';

class ModelRouter {
  static const _keywords = [
    'receipt',
    'audit',
    'analyze',
    'deduction',
  ];

  /// Selects model tier based on prompt content and length.
  /// - Defaults to sentinel (E2B lightweight).
  /// - Upgrades to auditor (E4B) if any keyword is present (case-insensitive) or prompt length > 300.
  static ModelTier select(String prompt) {
    final p = prompt.toLowerCase();
    for (final k in _keywords) {
      if (p.contains(k)) return ModelTier.auditor;
    }
    if (prompt.length > 300) return ModelTier.auditor;
    return ModelTier.sentinel;
  }
}
