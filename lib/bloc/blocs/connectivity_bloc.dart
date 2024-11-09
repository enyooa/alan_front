import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cash_control/bloc/events/connectivity_event.dart';
import 'package:cash_control/bloc/states/connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  ConnectivityBloc() : super(ConnectivityInitial()) {
    // Listen for changes in network connectivity
    on<CheckConnectivity>((event, emit) async {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        emit(ConnectivityFailure());
      } else {
        emit(ConnectivitySuccess(true));
      }
    });

    // Subscribe to network changes and emit states
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        add(CheckConnectivity());  // No internet connection
      } else {
        add(CheckConnectivity());  // Internet connection is restored
      }
    } as void Function(List<ConnectivityResult> event)?);
  }

  // Dispose of connectivity subscription when Bloc is closed
  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
