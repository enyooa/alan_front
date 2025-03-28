class SalesRow {
  final String productName;
  final double quantity;
  final double saleAmount;
  final double costAmount;
  final double profit;
  final String documentDate;

  SalesRow({
    required this.productName,
    required this.quantity,
    required this.saleAmount,
    required this.costAmount,
    required this.profit,
    required this.documentDate,
  });

  /// Парсит одну строку JSON
  factory SalesRow.fromJson(Map<String, dynamic> json) {
    return SalesRow(
      // Если поле отсутствует, подставим ''
      productName: json['product_name'] ?? '',

      // quantity = "10.000" => нужно tryParse
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,

      // sale_amount, cost_amount, profit уже числа (int/float), 
      // но безопасно приводим (как num?)?.toDouble() 
      saleAmount: (json['sale_amount'] as num?)?.toDouble() ?? 0.0,
      costAmount: (json['cost_amount'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,

      // Дата - храним как строку (если нужна DateTime, 
      // можно дополнительно делать DateTime.parse(...))
      documentDate: json['document_date']?.toString() ?? '',
    );
  }
}
