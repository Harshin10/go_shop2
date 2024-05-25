import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:go_shop/E-Shop/Pages/login_page.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool _isObscure = true; // State variable to toggle password visibility
  TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseStorage _imageStorage = FirebaseStorage.instance;
  XFile? pickedImage;
  bool isImageSelected = false;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedCountryCode = "+91";
  late String verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? file;

  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    checkNetworkStatus();
  }

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
    return Scaffold(
      body: OverlayLoaderWithAppIcon(
        isLoading: isLoading,
        overlayBackgroundColor: Colors.black,
        circularProgressColor: Color(0xff670099),
        appIcon: Image.asset('asset/logo.png'),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1920&h=1080&auto=format&fit=crop"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 70.0),
                  Bounceable(
                    onTap: () async {
                      imagedialoge(context);
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 75.0,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 73,
                            backgroundImage: isImageSelected
                                ? FileImage(file!)
                                : const NetworkImage(
                                        'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D')
                                    as ImageProvider<Object>,
                          ),
                        ),
                        Positioned(
                          bottom: -15,
                          left: 110,
                          child: IconButton(
                            onPressed: () {
                              imagedialoge(context);
                            },
                            icon: const Icon(Icons.add_a_photo_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300]!.withOpacity(0.5),
                            labelText: 'Username',
                            hintText: 'Enter your username',
                            prefixIcon:
                                const Icon(Icons.person, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your username';
                            } else if (value.length < 3) {
                              return 'Username must contain 3 or more characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        Row(
                          children: [
                            Container(
                              height: 64.0,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(0.5),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: CountryCodePicker(
                                onChanged: (CountryCode countryCode) {
                                  setState(() {
                                    selectedCountryCode =
                                        countryCode.toString();
                                  });
                                },
                                initialSelection: 'IN',
                                favorite: const ['+91', 'IN'],
                              ),
                            ),
                            const SizedBox(width: 14.0),
                            Expanded(
                              child: TextFormField(
                                controller: phoneNumberController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[300]!.withOpacity(0.5),
                                  labelText: 'Phone Number',
                                  hintText: 'Enter your Phone Number',
                                  prefixIcon: const Icon(
                                      Icons.phone_iphone_outlined,
                                      color: Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your Phone Number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300]!.withOpacity(0.5),
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            } else if (!RegExp(
                                    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
                                .hasMatch(value)) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            hintText: 'Enter your address',
                            filled: true,
                            fillColor: Colors.grey[300]!.withOpacity(0.5),
                            prefixIcon: const Icon(Icons.location_on,
                                color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your address';
                            } else if (value.length < 5) {
                              return 'Address must contain at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          controller: passwordcontroller,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your Password',
                            filled: true,
                            fillColor: Colors.grey[300]!.withOpacity(0.5),
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.black),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your Password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 25),
                        // Confirm Password TextFormField
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Re-enter your Password',
                            filled: true,
                            fillColor: Colors.grey[300]!.withOpacity(0.5),
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          validator: (value) {
                            if (value != passwordcontroller.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 25.0),
                        Container(
                          height: 48.0,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              if (_formKey.currentState!.validate()) {
                                if (file == null) {
                                  imagedialoge(context);
                                } else {
                                  try {
                                    await uploadAndRegister();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error on upload: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: isLoading
                                ? Lottie.asset('asset/lottie1.json')
                                : Text('Register'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> imagedialoge(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.image(
          Image.network(
            "https://cdn.dribbble.com/users/102974/screenshots/2726841/head_bob.gif",
            height: 200,
            fit: BoxFit.cover,
          ),
          title: Text(
            'ADD Profile!',
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text('Do you want to select the image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _registerUserWithoutImage();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                selectImage();
                Navigator.pop(context, 'CHANGE');
              },
              child: const Text('CHANGE'),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          file = File(image.path);
          isImageSelected = true;
        });
      }
    } catch (e) {}
  }

  Future<String> uploadImage(String childName, Uint8List file) async {
    Reference ref = _imageStorage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<void> addUserData(
    String name,
    int mobileNumber,
    String email,
    String address,
    String password,
    String countrycode,
    String downloadURL,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await FirebaseFirestore.instance.collection('users').add({
        'username': usernameController.text,
        'Phone Number': phoneNumberController.text,
        'email': emailController.text,
        'Address': addressController.text,
        'password': passwordcontroller.text,
        'countrycode': selectedCountryCode,
        'ProfileImage': downloadURL,
        'cart': [],
        'favorite': [],
        'newaddress':[],
         'buyproduct':[],
       
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registered Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Email already in use. Please use a different email.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during registration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _registerUserWithoutImage() async {
    setState(() {
      isLoading = true;
    });
    try {
      await addUserData(
        usernameController.text,
        int.tryParse(phoneNumberController.text) ?? 0,
        emailController.text,
        addressController.text,
        passwordcontroller.text,
        selectedCountryCode,
        '',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error on registration: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> uploadAndRegister() async {
    try {
      String downloadURL = '';

      if (file != null) {
        downloadURL = await uploadImage(
          'user_profile_images/${DateTime.now()}.jpg',
          file!.readAsBytesSync(),
        );
      }

      await addUserData(
        usernameController.text,
        int.tryParse(phoneNumberController.text) ?? 0,
        emailController.text,
        addressController.text,
        passwordcontroller.text,
        selectedCountryCode,
        downloadURL,
      );

      // Registration successful, navigate or show success message as needed
    } catch (e) {
      String errorMessage = 'Error during registration.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          // Handle other FirebaseAuthException codes as needed
          default:
            errorMessage = 'Registration failed. Please try again later.';
            break;
            
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );

      print('Error during registration: $e');
    }
  }
}
