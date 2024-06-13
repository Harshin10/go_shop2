// ignore_for_file: unused_result

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:go_shop/E-Shop/Pages/register_page.dart';
import 'package:go_shop/E-Shop/Widgets/bottomnav.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Define the network state provider
final networkProvider = StateNotifierProvider<NetworkNotifier, bool>((ref) {
  return NetworkNotifier();
});

class NetworkNotifier extends StateNotifier<bool> {
  NetworkNotifier() : super(true) {
    checkNetworkStatus();
  }

  Future<void> checkNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      state = false;
    } else {
      state = true;
    }
  }
}

// Define the auth provider
final authProvider = Provider((ref) => FirebaseAuth.instance);

// Define the GoogleSignIn provider
final googleSignInProvider = Provider((ref) => GoogleSignIn());

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final hasInternet = ref.watch(networkProvider);

    if (!hasInternet) {
      return NetworkErrorPage(onRefresh: () => ref.read(networkProvider.notifier).checkNetworkStatus());
    }

    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff670099),
      appIcon: Image.asset('asset/logo.png'),
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'asset/login.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Column(
                  children: [
                    const SizedBox(width: 8.0),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.grey[300]!.withOpacity(0.5),
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.grey[300]!.withOpacity(0.5),
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return GiffyDialog.image(
                            Image.network(
                              "https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExcWNhcmVndXJsYWJ1anI5MnE5bXc1aTIyaXl4N2pnYjRkMW1zZXF0YyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/xThtanqVawzQNeHD20/giphy.gif",
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            title: const Text('Forgot Password'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Enter your email address to reset your password:'),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(labelText: 'Email'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  resetPassword(emailController.text);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Reset'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Forgot Password?', style: TextStyle(color: Colors.red)),
                  ),
                ),
                Bounceable(
                   onTap: () async {
                  User? user = await _signInWithGoogle();
                  if (user != null) {
                    print('Successfully signed in with Google: ${user.displayName}');
                       Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Nav()),
        );
                  } else {
                    print('Failed to sign in with Google');
                  }
                },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 15,
                    width: MediaQuery.of(context).size.width / 7,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('asset/googlelogo.jpg'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                SizedBox(
                  height: 48.0,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:(){ 
                       _login(context);},
                    child: isLoading ? CircularProgressIndicator() : const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New User?', style: TextStyle(color: Colors.amber[100])),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const RegistrationPage(),
                              type: PageTransitionType.bottomToTop,
                            ),
                          );
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(message: "Password reset email sent. Please check your email."),
      );
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(message: "An error occurred while sending the reset email."),
      );
      print('Error during password reset: $e');
    }
  }


   Future<void> _login(BuildContext context) async {
        bool isInternetAvailable = await InternetConnectionChecker().hasConnection;

    setState(() {
      isLoading = true;
    });

    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
if (isInternetAvailable){
      if (_formKey.currentState!.validate()) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: "Your login is successful. Have a nice day",
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Nav()),
        );
      }} 
      else {
      if (context.mounted) {
       Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage(onRefresh: () {  },)));
      }
    }
    
    } catch (e) {
      String errorMessage = "An error occurred during login.";

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = "User not found. Please check your email.";
            break;
          case 'wrong-password':
            errorMessage = "Invalid password. Please try again.";
            break;
          case 'invalid-email':
            errorMessage = "Invalid email address. Please check your email.";
            break;
          default:
            errorMessage = "Login failed. Please try again.";
            break;
        }
      }

      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: errorMessage),
      );

      print('Error during login: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
     Future<User?> _signInWithGoogle() async {
    final googleSignIn = ref.read(googleSignInProvider);
    final auth = ref.read(authProvider);

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: "Failed to sign in with Google. Please try again."),
      );
      return null;
    }
  }

}
