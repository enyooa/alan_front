import 'package:equatable/equatable.dart';

abstract class StorageReceivingState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Начальное
class StorageReceivingInitial extends StorageReceivingState {}

/// Состояние "загружаем..."
class StorageReceivingLoading extends StorageReceivingState {}

/// Состояние "ошибка"
class StorageReceivingError extends StorageReceivingState {
  final String message;
  StorageReceivingError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Состояние: список поступлений загружен
class StorageReceivingListLoaded extends StorageReceivingState {
  final List<dynamic> receipts;
  StorageReceivingListLoaded({required this.receipts});

  @override
  List<Object?> get props => [receipts];
}

/// Состояние: поступления созданы
class StorageReceivingCreated extends StorageReceivingState {
  final String message;
  StorageReceivingCreated({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Состояние: поступление обновлено
class StorageReceivingUpdated extends StorageReceivingState {
  final String message;
  StorageReceivingUpdated({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Состояние: поступление удалено
class StorageReceivingDeleted extends StorageReceivingState {
  final String message;
  StorageReceivingDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Состояние: один документ + справочники
class StorageReceivingSingleLoaded extends StorageReceivingState {
  /// Объект документа (JSON), полученный напрямую
  final Map<String, dynamic> document;
  /// Справочники
  final List<dynamic> providers;
  final List<dynamic> warehouses;
  final List<dynamic> productSubCards;
  final List<dynamic> unitMeasurements;
  final List<dynamic> expenses;

  StorageReceivingSingleLoaded({
    required this.document,
    required this.providers,
    required this.warehouses,
    required this.productSubCards,
    required this.unitMeasurements,
    required this.expenses,
  });
}
