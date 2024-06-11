
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:go_shop/E-Shop/Pages/welcome_page.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  }
   catch (e) {
    log(e.toString());
  }

SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown
]);
    runApp(
    ProviderScope(
      child:MyApp()
    ),
  );
}

