import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

final introPageProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final bool hasShownIntro = prefs.getBool('hasShownIntro') ?? false;
  return hasShownIntro;
});

Future<void> setIntroShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasShownIntro', true);
}



final authProvider = StateNotifierProvider<AuthProvider, bool>((ref) => AuthProvider());

class AuthProvider extends StateNotifier<bool> {
  AuthProvider() : super(false);

  Future<void> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = true;
    } catch (_) {
      state = false; 
      rethrow; 
    }
  }
}
