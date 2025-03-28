// product_writeoff_state.dart

abstract class ProductWriteOffState {}

class ProductWriteOffInitial extends ProductWriteOffState {}

class ProductWriteOffLoading extends ProductWriteOffState {}

class ProductWriteOffCreated extends ProductWriteOffState {
  final String message;
  ProductWriteOffCreated({required this.message});
}

class ProductWriteOffError extends ProductWriteOffState {
  final String message;
  ProductWriteOffError({required this.message});
}
