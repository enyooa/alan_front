class DebtsReportState {
  final bool isLoading;
  final List<Map<String, dynamic>> documents;
  final List<Map<String, dynamic>> financialOrders;
  final String? errorMessage;

  DebtsReportState({
    this.isLoading = false,
    this.documents = const [],
    this.financialOrders = const [],
    this.errorMessage,
  });

  DebtsReportState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? documents,
    List<Map<String, dynamic>>? financialOrders,
    String? errorMessage,
  }) {
    return DebtsReportState(
      isLoading: isLoading ?? this.isLoading,
      documents: documents ?? this.documents,
      financialOrders: financialOrders ?? this.financialOrders,
      errorMessage: errorMessage,
    );
  }
}
