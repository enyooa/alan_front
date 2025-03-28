// product_transfer_state.dart

abstract class ProductTransferState {}

class ProductTransferInitial extends ProductTransferState {}
class ProductTransferLoading extends ProductTransferState {}
class ProductTransferCreated extends ProductTransferState {
  final String message;
  ProductTransferCreated({required this.message});
}
class ProductTransferError extends ProductTransferState {
  final String message;
  ProductTransferError({required this.message});
}
