import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_shop/E-Shop/Pages/login_page.dart';

class NetworkErrorPage extends ConsumerWidget {
  final VoidCallback onRefresh;

  NetworkErrorPage({required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GiffyDialog.image(
              Image.asset(
                "asset/network.gif",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Text('Network Error! Please check your internet connection.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var connectivityResult =
                    await Connectivity().checkConnectivity();
                if (connectivityResult != ConnectivityResult.none) {
                 
                  onRefresh();
                } else {
                
                  ref.read(networkProvider.notifier).checkNetworkStatus();
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
