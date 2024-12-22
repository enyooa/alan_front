class AdminCashState {
  final bool isLoading;
  final List<Map<String, String>> cashAccounts;
  final String? errorMessage;

  AdminCashState({
    required this.isLoading,
    required this.cashAccounts,
    this.errorMessage,
  });

  AdminCashState copyWith({
    bool? isLoading,
    List<Map<String, String>>? cashAccounts,
    String? errorMessage,
  }) {
    return AdminCashState(
      isLoading: isLoading ?? this.isLoading,
      cashAccounts: cashAccounts ?? this.cashAccounts,
      errorMessage: errorMessage,
    );
  }
}
