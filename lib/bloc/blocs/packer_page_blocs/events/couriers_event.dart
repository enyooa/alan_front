import 'package:equatable/equatable.dart';

abstract class CourierEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCouriersEvent extends CourierEvent {}
