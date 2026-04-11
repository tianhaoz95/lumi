class LineItem {
  final String description;
  final double amount;

  LineItem({required this.description, required this.amount});

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
        description: json['description'] as String,
        amount: (json['amount'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
      };
}

class ReceiptData {
  final String vendorName;
  final double totalAmount;
  final String currency;
  final String date;
  final List<LineItem> lineItems;

  ReceiptData({
    required this.vendorName,
    required this.totalAmount,
    required this.currency,
    required this.date,
    required this.lineItems,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) => ReceiptData(
        vendorName: json['vendor_name'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        currency: json['currency'] as String,
        date: json['date'] as String,
        lineItems: (json['line_items'] as List<dynamic>)
            .map((e) => LineItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'vendor_name': vendorName,
        'total_amount': totalAmount,
        'currency': currency,
        'date': date,
        'line_items': lineItems.map((e) => e.toJson()).toList(),
      };
}
