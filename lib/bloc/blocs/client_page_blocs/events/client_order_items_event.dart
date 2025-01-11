import 'package:equatable/equatable.dart';

abstract class ClientOrderItemsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchClientOrderItemsEvent extends ClientOrderItemsEvent {}

class ConfirmCourierDocumentEvent extends ClientOrderItemsEvent {
  final int courierDocumentId;

  ConfirmCourierDocumentEvent({required this.courierDocumentId});

  @override
  List<Object?> get props => [courierDocumentId];
}
