
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:go_shop/E-Shop/Pages/login_page.dart';
import 'package:go_shop/E-Shop/Widgets/check_first_time.dart';
import 'package:go_shop/E-Shop/provider/authprovider.dart';
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

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introPageFuture = ref.watch(introPageProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: introPageFuture.when(
        data: (hasShownIntro) {
          if (!hasShownIntro) {
            return IntroPage(onFinished: () async {
              await setIntroShown();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            });
          } else {
            return LoginPage();
          }
        },
        loading: () => Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Error: $err'),
          ),
        ),
      ),
    );
  }
}