class StorageReportItem {
  final int warehouseId;
  final String warehouseName;
  final int productId;
  final String productName;
  final double currentQuantity;
  final double currentCostPrice;
  final double totalInbound;
  final double totalOutbound;
  final double remainder;
  final double remainderValue;

  StorageReportItem({
    required this.warehouseId,
    required this.warehouseName,
    required this.productId,
    required this.productName,
    required this.currentQuantity,
    required this.currentCostPrice,
    required this.totalInbound,
    required this.totalOutbound,
    required this.remainder,
    required this.remainderValue,
  });

  // Фабричный конструктор для парсинга JSON
  // Пример фабричного конструктора StorageReportItem:
factory StorageReportItem.fromJson(Map<String, dynamic> json) {
  return StorageReportItem(
    warehouseId: json['warehouse_id'] ?? 0,
    warehouseName: json['warehouse_name'] ?? '',
    productId: json['product_id'] ?? 0,
    productName: json['product_name'] ?? '',
    currentQuantity: double.tryParse(json['current_quantity']?.toString() ?? '0') ?? 0,
    currentCostPrice: double.tryParse(json['current_cost_price']?.toString() ?? '0') ?? 0,
    totalInbound: double.tryParse(json['total_inbound']?.toString() ?? '0') ?? 0,
    totalOutbound: double.tryParse(json['total_outbound']?.toString() ?? '0') ?? 0,
    remainder: double.tryParse(json['remainder']?.toString() ?? '0') ?? 0,
    remainderValue: double.tryParse(json['remainder_value']?.toString() ?? '0') ?? 0,
  );
}

}
