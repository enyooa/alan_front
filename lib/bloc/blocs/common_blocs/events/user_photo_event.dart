import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class PhotoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SelectPhotoEvent extends PhotoEvent {
  final File photo;

  SelectPhotoEvent(this.photo);

  @override
  List<Object?> get props => [photo];
}

class UploadPhotoEvent extends PhotoEvent {
  final File photo;

  UploadPhotoEvent(this.photo);

  @override
  List<Object?> get props => [photo];
}
class FetchPhotoEvent extends PhotoEvent {}
