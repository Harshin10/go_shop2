import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_shop/E-Shop/Pages/login_page.dart';
import 'package:go_shop/E-Shop/Pages/welcome_page.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckFirstTime extends StatefulWidget {
  @override
  State<CheckFirstTime> createState() => _CheckFirstTimeState();
}

class _CheckFirstTimeState extends State<CheckFirstTime> {
      bool hasInternet = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: checkIfFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.hasError) {
              // Handle network error here
              return NetworkErrorPage(onRefresh: checkNetworkStatus);
            } else {
              bool isFirstTime = snapshot.data ?? false;
              return FutureBuilder<bool>(
                future: isNetworkAvailable(),
                builder: (context, networkSnapshot) {
                  if (networkSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (networkSnapshot.hasError || networkSnapshot.data == null) {
                       return NetworkErrorPage(onRefresh: checkNetworkStatus);
                    } else {
                      return isFirstTime ?
                       IntroPage() : LoginPage();
                    }
                  }
                },
              );
            }
          }
        },
      ),
    );
  }

   Future<void> checkNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        hasInternet = false;
      });
    }
    else{
       setState(() {
        hasInternet = true;
      });
    }
  }
  Future<bool> checkIfFirstTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('first_time') ?? true;

  if (isFirstTime) {
    await prefs.setBool('first_time', false);
  }

  return isFirstTime;
}
Future<bool> isNetworkAvailable() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
}