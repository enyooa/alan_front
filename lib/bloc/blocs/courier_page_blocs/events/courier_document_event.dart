
import 'package:equatable/equatable.dart';

abstract class CourierDocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCourierDocumentsEvent extends CourierDocumentEvent {}
