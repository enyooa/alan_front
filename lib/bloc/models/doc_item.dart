class DocItem {
  final int docId;
  final String type;
  final String? documentNumber;
  final String documentDate; // или DateTime
  final String? providerName;
  final double docTotalSum;

  DocItem({
    required this.docId,
    required this.type,
    required this.documentDate,
    required this.docTotalSum,
    this.documentNumber,
    this.providerName,
  });

  factory DocItem.fromJson(Map<String, dynamic> json) {
    return DocItem(
      docId: json['doc_id'] ?? 0,
      type: json['type'] ?? '',
      documentNumber: json['document_number'],
      documentDate: json['document_date']?.toString() ?? '',
      providerName: json['provider_name'],
      docTotalSum: (json['doc_total_sum'] is num)
          ? (json['doc_total_sum'] as num).toDouble()
          : 0.0,
    );
  }
}
