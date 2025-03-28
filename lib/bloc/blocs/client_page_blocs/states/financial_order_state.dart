abstract class FinancialOrderState {}

class FinancialOrderInitial extends FinancialOrderState {}

class FinancialOrderLoading extends FinancialOrderState {}

class FinancialOrderLoaded extends FinancialOrderState {
  final List<Map<String, dynamic>> financialOrders;

  FinancialOrderLoaded(this.financialOrders);
}
class FinancialOrderSaved extends FinancialOrderState {}

class FinancialOrderError extends FinancialOrderState {
  final String message;

  FinancialOrderError(this.message);
}
