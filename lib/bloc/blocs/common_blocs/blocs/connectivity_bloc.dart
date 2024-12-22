

import 'package:cash_control/bloc/blocs/common_blocs/events/connectivity_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/connectivity_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();

  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<CheckConnectivity>((event, emit) async {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        emit(ConnectivityLost());
      } else {
        emit(ConnectivityRestored());
      }

      // Listen for connectivity changes
      _connectivity.onConnectivityChanged.listen((result) {
        if (result == ConnectivityResult.none) {
          add(CheckConnectivity());
        } else {
          add(CheckConnectivity());
        }
      });
    });
  }
}