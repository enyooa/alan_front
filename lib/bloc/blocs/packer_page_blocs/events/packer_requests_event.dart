import 'package:equatable/equatable.dart';

abstract class RequestsEvent extends Equatable {
  const RequestsEvent();

  @override
  List<Object?> get props => [];
}

class FetchRequestsEvent extends RequestsEvent {}

class SaveRequestsEvent extends RequestsEvent {
  final List<Map<String, dynamic>> requests;

  const SaveRequestsEvent({required this.requests});

  @override
  List<Object?> get props => [requests];
}
