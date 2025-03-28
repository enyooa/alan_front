// storage_references_event.dart

import 'package:equatable/equatable.dart';

abstract class StorageReferencesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// 1) Fetch references
class FetchAllInstancesEvent extends StorageReferencesEvent {}

// 2) Store income
class CreateStoreIncomeEvent extends StorageReferencesEvent {
  final Map<String, dynamic> payload; 
  // This includes provider_id, document_date, products[], expenses[]

  CreateStoreIncomeEvent({required this.payload});

  @override
  List<Object?> get props => [payload];
}
