
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:go_shop/E-Shop/Widgets/check_first_time.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown
]);
   runApp(
     CheckFirstTime(),
  );
}

