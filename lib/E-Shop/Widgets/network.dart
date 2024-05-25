import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class NetworkErrorPage extends StatefulWidget {
  final VoidCallback onRefresh;

  NetworkErrorPage({required this.onRefresh});
  @override
  _NetworkErrorPageState createState() => _NetworkErrorPageState();
}

class _NetworkErrorPageState extends State<NetworkErrorPage> {
  @override
  Widget build(BuildContext context) {
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
                  // If network is available, call the onRefresh callback
                  widget.onRefresh();
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
