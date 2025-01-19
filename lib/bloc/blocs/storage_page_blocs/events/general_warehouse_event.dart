import 'package:equatable/equatable.dart';

abstract class GeneralWarehouseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchGeneralWarehouseEvent extends GeneralWarehouseEvent {}

class WriteOffGeneralWarehouseEvent extends GeneralWarehouseEvent {
  final List<Map<String, dynamic>> writeOffs;

  WriteOffGeneralWarehouseEvent({required this.writeOffs});

  @override
  List<Object?> get props => [writeOffs];
}
