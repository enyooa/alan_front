class SaleRow {
  final String productName;
  final double quantity;
  final double saleAmount;
  final double costAmount;
  final double profit;
  final String documentDate;

  SaleRow({
    required this.productName,
    required this.quantity,
    required this.saleAmount,
    required this.costAmount,
    required this.profit,
    required this.documentDate,
  });

  factory SaleRow.fromJson(Map<String, dynamic> json) {
    return SaleRow(
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      saleAmount: (json['sale_amount'] as num).toDouble(),
      costAmount: (json['cost_amount'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      documentDate: json['document_date'] as String,
    );
  }
}
