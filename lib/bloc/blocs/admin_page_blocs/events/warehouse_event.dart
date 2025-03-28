import 'package:equatable/equatable.dart';

abstract class WarehouseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchWarehousesEvent extends WarehouseEvent {}
