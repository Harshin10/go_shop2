import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged
      .expand((connectivityList) => connectivityList)
      .distinct(); // Optional: Ensure only distinct connectivity results are emitted
});





final introPageProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final bool hasShownIntro = prefs.getBool('hasShownIntro') ?? false;
  return hasShownIntro;
});

Future<void> setIntroShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasShownIntro', true);
}


