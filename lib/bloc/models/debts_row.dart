class DebtsRow {
  final String rowType;      // row_type
  final String? label;       // label (только если row_type=='group')
  final String? name;        // provider, doc, client
  final double? incoming;
  final double? outgoing;
  final double? balance;

  DebtsRow({
    required this.rowType,
    this.label,
    this.name,
    this.incoming,
    this.outgoing,
    this.balance,
  });

  factory DebtsRow.fromJson(Map<String, dynamic> json) {
    return DebtsRow(
      rowType: json['row_type'] ?? '',
      label: json['label'],
      name: json['name'],
      incoming: (json['incoming'] != null) ? (json['incoming'] as num).toDouble() : null,
      outgoing: (json['outgoing'] != null) ? (json['outgoing'] as num).toDouble() : null,
      balance: (json['balance'] != null) ? (json['balance'] as num).toDouble() : null,
    );
  }
}
