import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

// Events for ConnectivityBloc
abstract class ConnectivityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckConnectivity extends ConnectivityEvent {}
