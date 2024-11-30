import 'package:equatable/equatable.dart';

abstract class ConnectivityState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityLost extends ConnectivityState {}

class ConnectivityRestored extends ConnectivityState {}
