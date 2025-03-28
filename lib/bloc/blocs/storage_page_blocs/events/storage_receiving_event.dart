import 'package:equatable/equatable.dart';

abstract class StorageReceivingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Создание пачки поступлений
class CreateBulkStorageReceivingEvent extends StorageReceivingEvent {
  final List<Map<String, dynamic>> receivings;
  CreateBulkStorageReceivingEvent({required this.receivings});

  @override
  List<Object?> get props => [receivings];
}

/// Загрузка списка всех поступлений
class FetchAllReceiptsEvent extends StorageReceivingEvent {}

/// Обновление (PUT)
class UpdateIncomeEvent extends StorageReceivingEvent {
  final int docId;
  final Map<String, dynamic> updatedData;
  UpdateIncomeEvent({required this.docId, required this.updatedData});

  @override
  List<Object?> get props => [docId, updatedData];
}

/// Удаление (DELETE)
class DeleteIncomeEvent extends StorageReceivingEvent {
  final int docId;
  DeleteIncomeEvent({required this.docId});

  @override
  List<Object?> get props => [docId];
}

/// Загрузка одного документа + справочников
class FetchSingleReceiptEvent extends StorageReceivingEvent {
  final int docId;
  FetchSingleReceiptEvent({required this.docId});

  @override
  List<Object?> get props => [docId];
}
