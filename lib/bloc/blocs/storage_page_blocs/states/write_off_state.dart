import 'package:equatable/equatable.dart';

abstract class WriteOffState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WriteOffInitial extends WriteOffState {}
class WriteOffLoading extends WriteOffState {}

// when we get the list
class WriteOffListLoaded extends WriteOffState {
  final List<dynamic> writeOffDocs;
  WriteOffListLoaded({required this.writeOffDocs});

  @override
  List<Object?> get props => [writeOffDocs];
}

class WriteOffCreated extends WriteOffState {
  final String message;
  WriteOffCreated({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// For fetching a single write‑off document
class WriteOffSingleLoaded extends WriteOffState {
  final Map<String, dynamic> document;
  // Optionally include references if needed:
  final List<dynamic>? warehouses;
  final List<dynamic>? products;
  final List<dynamic>? units;
  WriteOffSingleLoaded({
    required this.document,
    this.warehouses,
    this.products,
    this.units,
  });
  @override
  List<Object?> get props => [document];
}

class WriteOffUpdated extends WriteOffState {
  final String message;
  WriteOffUpdated({required this.message});

  @override
  List<Object?> get props => [message];
}

class WriteOffDeleted extends WriteOffState {
  final String message;
  WriteOffDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

class WriteOffError extends WriteOffState {
  final String message;
  WriteOffError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
