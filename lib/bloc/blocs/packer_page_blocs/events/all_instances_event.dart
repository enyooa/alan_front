import 'package:equatable/equatable.dart';

abstract class AllInstancesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAllInstancesEvent extends AllInstancesEvent {}
