
import 'package:equatable/equatable.dart';

abstract class StorageReceivingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateBulkStorageReceivingEvent extends StorageReceivingEvent {
  final List<Map<String, dynamic>> receivings;

  CreateBulkStorageReceivingEvent({required this.receivings});

  @override
  List<Object?> get props => [receivings];
}
