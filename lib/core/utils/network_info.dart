import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity connectivity;

  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    final List<ConnectivityResult> result = await connectivity
        .checkConnectivity();
    return result.isNotEmpty &&
        (result.contains(ConnectivityResult.mobile) ||
            result.contains(ConnectivityResult.wifi) ||
            result.contains(ConnectivityResult.ethernet));
  }

  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((
      List<ConnectivityResult> result,
    ) {
      return result.isNotEmpty &&
          (result.contains(ConnectivityResult.mobile) ||
              result.contains(ConnectivityResult.wifi) ||
              result.contains(ConnectivityResult.ethernet));
    });
  }
}
