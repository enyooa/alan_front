import 'package:equatable/equatable.dart';

abstract class WriteOffEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// 1) Fetch all write-offs
class FetchWriteOffsEvent extends WriteOffEvent {}

class FetchSingleWriteOffEvent extends WriteOffEvent {
  final int docId;
  FetchSingleWriteOffEvent({required this.docId});
  @override
  List<Object?> get props => [docId];
}

// 2) Create
class CreateWriteOffEvent extends WriteOffEvent {
  final Map<String, dynamic> payload;

  CreateWriteOffEvent({required this.payload});
  
  @override
  List<Object?> get props => [payload];
}

// 3) Update (if needed)
class UpdateWriteOffEvent extends WriteOffEvent {
  final int docId;
  final Map<String, dynamic> updatedData;

  UpdateWriteOffEvent({required this.docId, required this.updatedData});
  
  @override
  List<Object?> get props => [docId, updatedData];
}

// 4) Delete
class DeleteWriteOffEvent extends WriteOffEvent {
  final int docId;

  DeleteWriteOffEvent({required this.docId});

  @override
  List<Object?> get props => [docId];
}
