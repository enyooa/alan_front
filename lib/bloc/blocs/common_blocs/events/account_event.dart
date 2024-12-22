import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class AccountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUserData extends AccountEvent {}

class UploadPhoto extends AccountEvent {
  final File photo;

  UploadPhoto(this.photo);

  @override
  List<Object?> get props => [photo];
}

class ToggleNotification extends AccountEvent {
  final bool isEnabled;

  ToggleNotification(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class Logout extends AccountEvent {}
