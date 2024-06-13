import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkStatusProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged
      .map((connectivityResultList) => _mapConnectivityResults(connectivityResultList));
     
});
ConnectivityResult _mapConnectivityResults(List<ConnectivityResult> results) {
  if (results.contains(ConnectivityResult.wifi)) {
    return ConnectivityResult.wifi;
  } else if (results.contains(ConnectivityResult.mobile)) {
    return ConnectivityResult.mobile;
  } else {
    return ConnectivityResult.none;
  }
}
final isConnectedProvider = StateProvider<bool>((ref) {
  final status = ref.watch(networkStatusProvider).asData?.value ?? ConnectivityResult.none;
  return status != ConnectivityResult.none;
});

class NetworkErrorPage extends ConsumerWidget {
  static const routeName = '/network_error';
  final VoidCallback onRefresh;

  const NetworkErrorPage({required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "asset/network.gif",
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text('Network Error! Please check your internet connection.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var connectivityResult = await Connectivity().checkConnectivity();
                if (connectivityResult != ConnectivityResult.none) {
                  onRefresh();
                } else {
                  ref.read(isConnectedProvider.state).state = false;
                }
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
