class ReferenceState {
  final Map<String, List<Map<String, dynamic>>> references;
  final bool isLoading;
  final String? errorMessage;

  ReferenceState({
    required this.references,
    this.isLoading = false,
    this.errorMessage,
  });

  ReferenceState copyWith({
    Map<String, List<Map<String, dynamic>>>? references,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReferenceState(
      references: references ?? this.references,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}