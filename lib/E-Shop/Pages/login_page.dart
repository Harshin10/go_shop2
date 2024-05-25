import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:go_shop/E-Shop/Widgets/bottomnav.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:go_shop/E-Shop/Pages/register_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordController = TextEditingController();
    final auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedCountryCode = "+91"; // Set the default country code
  String errorMessage = '';
  bool isLoading = false;
  String verificationId = "";
  bool otpSent = false;
  bool hasInternet = true;
  bool _isObscure = true;
  @override
  void initState() {
    super.initState();
    checkNetworkStatus();
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  Future<void> checkNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        hasInternet = false;
      });
    } else {
      setState(() {
        hasInternet = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasInternet) {
      return NetworkErrorPage(onRefresh: checkNetworkStatus);
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
              image: NetworkImage(
                  'https://images.unsplash.com/photo-1619611191741-692703d71d51?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fHdhbGxwYXBlciUyMGZvciUyMG1vYmlsZXxlbnwwfHwwfHx8MA%3D%3D'),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Column(
                  children: [
                    //  if (!otpSent)
                    // Container(
                    //   height: 64.0,
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey[300]!.withOpacity(0.5),
                    //     border: Border.all(
                    //       color: Colors.black,
                    //     ),
                    //     borderRadius: BorderRadius.circular(20.0),
                    //   ),
                    //   child: CountryCodePicker(
                    //     onChanged: (CountryCode countryCode) {
                    //       setState(() {
                    //         selectedCountryCode = countryCode.toString();
                    //       });
                    //     },
                    //     initialSelection: 'IN',
                    //     favorite: ['+91', 'IN'],
                    //   ),
                    // ),
                    const SizedBox(width: 8.0),
                    TextFormField(
                      controller: emailcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.grey[300]!.withOpacity(0.5),
                        hintText: ' Email',
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
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
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
                 Align(alignment: Alignment.bottomRight,
                   child: TextButton(
                   
                    onPressed: () {
                      // Show a dialog to enter the email address
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
                                const Text(
                                    'Enter your email address to reset your password:'),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: emailcontroller,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration:
                                      const InputDecoration(labelText: 'Email'),
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
                                  // Reset password when the "Reset" button is tapped
                                  resetPassword(emailcontroller.text);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Reset'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Forgot Password?',
                        style: TextStyle(color: Colors.red)),
                                   ),
                 ),
              
Bounceable(
  onTap: ()   async {
          User? user = await _signInWithGoogle();
          if (user != null) {
            print('Successfully signed in with Google: ${user.displayName}');
          } else {
            print('Failed to sign in with Google');
          }
        },
  child: Container(
            height: MediaQuery.of(context).size.height/15,
            width: MediaQuery.of(context).size.width/7,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'asset/googlelogo.jpg'),
                fit: BoxFit.fill,
              ),
            ),),
),
                // TextFormField(
                //   controller: passwordController,
                //   obscureText: true,
                //   decoration: InputDecoration(
                //     hintText: 'Enter your password',
                //       filled: true,
                //                        fillColor: Colors.grey[300]!.withOpacity(0.5),
                //     prefixIcon: Icon(Icons.lock_outline,color: Colors.black,),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(20.0),
                //     ),
                //   ),
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter your password';
                //     }
                //     return null;
                //   },
                // ),

SizedBox(
                  height:8.0,),

                SizedBox(
                  height: 48.0,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        String password = passwordController.text.trim();
                        String email = emailcontroller.text.trim();

                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.success(
                            message:
                                "Your login is successful. Have a nice day",
                          ),
                        );

                       
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  Nav()),
                        );
                      } catch (e) {
                        String errorMessage = "An error occurred during login.";

                        if (e is FirebaseAuthException) {
                          switch (e.code) {
                            case 'user-not-found':
                              errorMessage =
                                  "User not found. Please check your email.";
                              break;
                            case 'wrong-password':
                              errorMessage =
                                  "Invalid password. Please try again.";
                              break;
                            case 'invalid-email':
                              errorMessage =
                                  "Invalid email address. Please check your email.";
                              break;
                            default:
                              errorMessage = "Login failed. Please try again .";
                              break;
                          }
                        }

                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: errorMessage,
                          ),
                        );

                        print('Error during login: $e');
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: isLoading
                        ? Lottie.asset('asset/lottie1.json')
                        : const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //  if (!otpSent)
                    // TextButton(
                    //   onPressed: () {
                    //     // Navigate to forget password page
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (context) => ForgetPassword()),
                    //     );
                    //   },
                    //   child: Text(
                    //     'Forget Password?',
                    //     style: TextStyle(color: Colors.red),
                    //   ),
                    // ),
                    const Text(
                      "Didn't have an account",
                      style: TextStyle(color: Colors.red),
                    ),

                    Container(
                      height: 20.0,
                      width: 1.0,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to signup page
                    
                          Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: RegistrationPage(),
                        ),
                      );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                          Icon(Icons.login_outlined, color: Colors.blueGrey),
                        ],
                      ),
                    ),
                  ],
                ),
                
              ]),

              //    Container(
              //   width:300,
              //   height:80,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     mainAxisSize: MainAxisSize.min,
              //     children: <Widget>[
              //       Container(
              //         // decoration: BoxDecoration(color: Colors.blue),
              //           child:
              //           Image.network(
              //               'http://pngimg.com/uploads/google/google_PNG19635.png',
              //               fit:BoxFit.cover
              //           )
              //       ),
              //       SizedBox(
              //         width: 5.0,
              //       ),
              //       Text('Sign-in with Google')
              //     ],
              //   ),
              // )
            ),
          ),
        ),
      ),
    );
  }
  //  Future<void> _requestOtp() async {
  //   // Implement the logic to request OTP here
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     // Simulate a delay for demonstration purposes
  //     await Future.delayed(Duration(seconds: 2));

  //     // Mocking successful OTP request

  //     setState(() {
  //       otpSent = true;
  //     });
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // Future<void> _verifyOtp() async {
  //   // Implement the logic to verify OTP here
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     // Simulate a delay for demonstration purposes
  //     await Future.delayed(Duration(seconds: 2));

  //     // Mocking successful OTP verification

  //     // Navigate to the next screen or perform any other action
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // void _resetOtp() {
  //   setState(() {
  //     otpSent = false;
  //   });
  // }
//   Future<void> _resetPassword() async {
//    String email = emailController.text;
//   if (formKey.currentState!.validate()) {
//     try {

//       // Store the email and reset status in Firestore
//       await FirebaseFirestore.instance.collection('password_reset').doc(email).set({
//         'email': email,
//         'resetStatus': true,
//         'resetRequested': FieldValue.serverTimestamp(),
//       });

//       // Send the password reset email
//       await FirebaseAuth.instance.sendPasswordResetEmail(
//         email: email,
//       );

//       showTopSnackBar(
//         Overlay.of(context),
//         CustomSnackBar.success(
//           message: "Password reset email sent. Check your email for instructions.",
//         ),
//       );
//       print('Password reset email sent');
//     } catch (e) {
//       showTopSnackBar(
//         Overlay.of(context),
//         CustomSnackBar.error(
//           message: "$e",
//         ),
//       );
//       print('Error sending password reset email: $e');
//     } finally {
//       await FirebaseFirestore.instance.collection('password_reset').doc(email).update({
//         'resetStatus': false,
//         'resetCompleted': FieldValue.serverTimestamp(),
//       });

//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
// }
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Show success message or navigate to a success screen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Password Reset Email Sent'),
            content: const Text('Check your email to reset your password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Show an error message if something goes wrong
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Failed to send password reset email. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      print('Error sending password reset email: $e');
    }
  }
   Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in process.
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }
  // Future<void> _resetPassword(String email) async {
  //  String email = emailcontroller.text;

  //   try {

  //     // Store the email and reset status in Firestore
  //     await FirebaseFirestore.instance.collection('password_reset').doc(email).set({
  //       'email': email,
  //       'resetStatus': true,
  //       'resetRequested': FieldValue.serverTimestamp(),
  //     });

  //     // Send the password reset email
  //     await FirebaseAuth.instance.sendPasswordResetEmail(
  //       email: email,
  //     );

  //     showTopSnackBar(
  //       Overlay.of(context),
  //       CustomSnackBar.success(
  //         message: "Password reset email sent. Check your email for instructions.",
  //       ),
  //     );
  //     print('Password reset email sent');
  //   } catch (e) {
  //     showTopSnackBar(
  //       Overlay.of(context),
  //       CustomSnackBar.error(
  //         message: "$e",
  //       ),
  //     );
  //     print('Error sending password reset email: $e');
  //   } finally {
  //     await FirebaseFirestore.instance.collection('password_reset').doc(email).update({
  //       'resetStatus': false,
  //       'resetCompleted': FieldValue.serverTimestamp(),
  //     });

  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
}
