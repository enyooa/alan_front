abstract class ExpenseState {}
class ExpenseInitial extends ExpenseState {}
class ExpenseLoading extends ExpenseState {}
class ExpenseLoaded extends ExpenseState {
  final List<Map<String, dynamic>> expenses; 
  // Пример: [{'name': 'Фрахт', 'amount': 800000.0}, ...]
  
  ExpenseLoaded(this.expenses);
}
class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}

// If you have a single expense or a list
class SingleExpenseLoaded extends ExpenseState {
  final Map<String, dynamic> expenseData;
  SingleExpenseLoaded(this.expenseData);
}

class ExpenseCreatedSuccess extends ExpenseState {
  final String message;
  ExpenseCreatedSuccess(this.message);
}

class ExpenseUpdatedSuccess extends ExpenseState {
  final String message;
  ExpenseUpdatedSuccess(this.message);
}
