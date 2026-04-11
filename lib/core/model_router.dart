enum ModelTier { E2B, E4B }

class ModelRouter {
  static const _keywords = [
    'receipt',
    'audit',
    'analyze',
    'deduction',
  ];

  /// Selects model tier based on prompt content and length.
  /// - Defaults to E2B.
  /// - Upgrades to E4B if any keyword is present (case-insensitive) or prompt length > 300.
  static ModelTier select(String prompt) {
    final p = prompt.toLowerCase();
    for (final k in _keywords) {
      if (p.contains(k)) return ModelTier.E4B;
    }
    if (prompt.length > 300) return ModelTier.E4B;
    return ModelTier.E2B;
  }
}
