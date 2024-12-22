import 'package:equatable/equatable.dart';

abstract class PhotoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PhotoInitial extends PhotoState {}

class PhotoLoading extends PhotoState {}

class PhotoSuccess extends PhotoState {
  final String photoUrl;

  PhotoSuccess(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

class PhotoError extends PhotoState {
  final String message;

  PhotoError(this.message);

  @override
  List<Object?> get props => [message];
}
