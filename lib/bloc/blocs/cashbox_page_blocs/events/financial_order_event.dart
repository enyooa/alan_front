abstract class FinancialOrderEvent {}

class FetchFinancialOrdersEvent extends FinancialOrderEvent {}

class AddFinancialOrderEvent extends FinancialOrderEvent {
  final Map<String, dynamic> orderData;

  AddFinancialOrderEvent(this.orderData);
}

class EditFinancialOrderEvent extends FinancialOrderEvent {
  final int orderId;
  final Map<String, dynamic> updatedOrderData;

  EditFinancialOrderEvent(this.orderId, this.updatedOrderData);
}

class DeleteFinancialOrderEvent extends FinancialOrderEvent {
  final int orderId;

  DeleteFinancialOrderEvent(this.orderId);
}
