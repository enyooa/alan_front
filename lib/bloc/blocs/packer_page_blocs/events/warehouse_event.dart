import 'package:equatable/equatable.dart';

abstract class PackagingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPackagingDataEvent extends PackagingEvent {
  final DateTime startDate;
  final DateTime endDate;

  FetchPackagingDataEvent({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
