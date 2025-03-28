abstract class ExpenseEvent {}
class FetchExpensesEvent extends ExpenseEvent {}

// Create
class CreateExpenseEvent extends ExpenseEvent {
  final String name;
  final double? amount;
  CreateExpenseEvent({required this.name, this.amount});
}

// Single fetch
class FetchSingleExpenseEvent extends ExpenseEvent {
  final int id;
  FetchSingleExpenseEvent({required this.id});
}

// Update
class UpdateExpenseEvent extends ExpenseEvent {
  final int id;
  final Map<String, dynamic> updatedFields;
  UpdateExpenseEvent({required this.id, required this.updatedFields});
}
