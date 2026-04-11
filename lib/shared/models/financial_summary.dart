class FinancialSummary {
  final double totalExpenses;
  final double totalMiles;
  final double estimatedDeduction;

  FinancialSummary({
    required this.totalExpenses,
    required this.totalMiles,
    required this.estimatedDeduction,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) => FinancialSummary(
        totalExpenses: (json['total_expenses'] as num).toDouble(),
        totalMiles: (json['total_miles'] as num).toDouble(),
        estimatedDeduction: (json['estimated_deduction'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'total_expenses': totalExpenses,
        'total_miles': totalMiles,
        'estimated_deduction': estimatedDeduction,
      };
}
