abstract class ConnectivityState {}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivitySuccess extends ConnectivityState {
  final bool isConnected;

  ConnectivitySuccess(this.isConnected);
}

class ConnectivityFailure extends ConnectivityState {}
