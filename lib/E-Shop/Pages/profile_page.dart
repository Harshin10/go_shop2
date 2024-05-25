import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:easy_loader/easy_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:go_shop/E-Shop/Pages/login_page.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
    TextEditingController numController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? file;
  XFile? pickedImage;
  bool isImageSelected = false;

  String? name = '';
  String? email = '';
  String? address = '';
  String? countrycode = '';
  String? mobile = '';
  String? image = '';

  FirebaseAuth auth = FirebaseAuth.instance;
  bool isEditingnum = false;

  bool isEditingName = false;
  bool isEditingAddress = false;
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
      nameController.text = name!;
      addressController.text = address!;
      _getDataFromDatabase();
    }
  }

  Future<void> _getDataFromDatabase() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userData = snapshot.docs.first
            .data(); // Access the data from the first document

        setState(() {
          name = userData['username'] ?? '';
          email = userData['email'] ?? '';
          address = userData['Address'] ?? '';
          image = userData['ProfileImage'] ?? '';
          countrycode = userData['countrycode'] ?? '';
          mobile = userData['Phone Number'] ?? '';
        });
      } else {
        print("No document found");
      }
    } catch (e) {
      print("Error getting data from the database: $e");
    }
  }

  Future<void> _updateDataToDatabase() async {
    try {
      if (formKey.currentState!.validate()) {
        try {
          var snapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: auth.currentUser!.email)
              .get();
          if (snapshot.docs.isNotEmpty) {
            if (isImageSelected) {}
            var documentId = snapshot.docs.first.id;

            await FirebaseFirestore.instance
                .collection('users')
                .doc(documentId) // Specify the document ID using .doc
                .update({
              'username': name,
              'Address': address,
              'ProfileImage': image,
              'Phone Number':mobile,
            });

            print("Data updated successfully");
          } else {
            print("No document found");
          }
        } catch (e) {
          print("Error updating data to the database: $e");
        }
      }
    } catch (e) {
      print("Error in _updateDataToDatabase: $e");
    }
  }
    Widget _buildProfileImage2() {
    if (!hasInternet) {
      return NetworkErrorPage(onRefresh: checkNetworkStatus);
    } else if (image != null && image!.isNotEmpty) {
      return Bounceable(
        onTap: () {
          showDialogWithImage(context);
        },
        child: Container(
               
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: isImageSelected ? FileImage(file!) : NetworkImage(image!)as ImageProvider<Object>,
            ),
          ),
        )


      );
    } else {
      return Bounceable(
        onTap: () {
          showDialogWithImage(context);
        },
        child: Container(
          width: 100, // Set the width as needed
          height: 100, // Set the height as needed
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: isImageSelected
                  ? FileImage(file!)
                  : NetworkImage(
                      'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                    ) as ImageProvider<Object>,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildProfileImage() {
    if (!hasInternet) {
      return NetworkErrorPage(onRefresh: checkNetworkStatus);
    } else if (image != null && image!.isNotEmpty) {
      return Bounceable(
        onTap: () {
          showDialogWithImage(context);
        },
        child: ClipOval(
  child: Container(
    width: 200, // specify the desired width if needed
    height: 200, // specify the desired height if needed
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(
        fit: BoxFit.cover,
        image: isImageSelected ? FileImage(file!) : NetworkImage(image!)as ImageProvider<Object>,
      ),
    ),
  ),
)


      );
    } else {
      return Bounceable(
        onTap: () {
          showDialogWithImage(context);
        },
        child: Container(
          width: 100, // Set the width as needed
          height: 100, // Set the height as needed
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: isImageSelected
                  ? FileImage(file!)
                  : NetworkImage(
                      'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                    ) as ImageProvider<Object>,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasInternet) {
      return NetworkErrorPage(onRefresh: checkNetworkStatus);
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            SizedBox(
                height: 250,
                width: double.infinity,
                child: _buildProfileImage2()),
            Container(
              margin: EdgeInsets.fromLTRB(15, 200, 15, 15),
              child: Column(
                children: [
                  Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 75.0,
                                  backgroundColor: Colors.white,
                                  child: _buildProfileImage(),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      ListTile(
                                          leading: Icon(Icons.person),
                                          title: Text(
                                            name!,
                                            style: GoogleFonts.alegreyaSansSc(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [],
                                ),
                                Divider(),
                                ListTile(
                                  title: Text("Name"),
                                  subtitle: isEditingName
                                      ? Form(
                                          key: formKey,
                                          child: TextFormField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                              hintText: "Enter your name",
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter a name';
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      : Text(name!),
                                  leading: Icon(Icons.person),
                                  trailing: IconButton(
                                    icon: isEditingName
                                        ? Icon(Icons.save)
                                        : Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        if (isEditingName) {
                                          if (formKey.currentState!
                                              .validate()) {
                                            name = nameController.text;
                                            _updateDataToDatabase();
                                          }
                                        }
                                        isEditingName = !isEditingName;
                                      });
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.phone_iphone_outlined),
                                  title: Text(
                                    "Mobile Number",
                                  ),
                                  subtitle: isEditingnum ? Form(
                                          key: formKey,
                                          child:TextFormField(
  controller: numController,
  decoration: InputDecoration(
    hintText: "Enter your mobile number",
  ),
  validator: (value) {
    if (value!.isEmpty) {
      return 'Please enter mobile number';
    }
    // Regular expression for a generic mobile phone number
    final RegExp phoneRegex = RegExp(r'^[0-9+\(\)#\.\s\/-]{6,20}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  },
),

                                        )
                                      : Text('${countrycode!}  ${mobile!}'),


trailing: IconButton(
                                    icon: isEditingnum
                                        ? Icon(Icons.save)
                                        : Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        if (isEditingnum) {
                                          if (formKey.currentState!
                                              .validate()) {
                                            mobile = numController.text;
                                            _updateDataToDatabase();
                                          }
                                        }
                                        isEditingnum = !isEditingnum;
                                      });
                                    },
                                  ),




                                  
                                ),
                                ListTile(
                                  title: Text("Email"),
                                  subtitle: Text(email!),
                                  leading: Icon(Icons.email),
                                ),
                                ListTile(
                                  title: Text("Address"),
                                  subtitle: isEditingAddress
                                      ? Form(
                                          key: formKey,
                                          child: TextFormField(
  controller: addressController,
  decoration: InputDecoration(
    hintText: "Enter your address",
  ),
  validator: (value) {
    if (value!.isEmpty) {
      return 'Please enter an address';
    }
    
    // Split the input value into words

    // Check if the number of words is less than 5
    if (value.length < 5) {
      return 'Address must contain at least 5 words';
    }
    
    return null;
  },
),

                                        )
                                      : Text(address!),
                                  leading: Icon(Icons.add_home_work_outlined),
                                  trailing: IconButton(
                                    icon: isEditingAddress
                                        ? Icon(Icons.save)
                                        : Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        if (isEditingAddress) {
                                          if (formKey.currentState!
                                              .validate()) {
                                            address = addressController.text;
                                            _updateDataToDatabase();
                                          }
                                        }
                                        isEditingAddress = !isEditingAddress;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("About"),
                          subtitle: Text(
                              "  'Go shop' typically refers to an online shopping platform or service where consumers can browse and purchase products over the internet. It is a convenient way for people to shop without physically visiting brick-and-mortar stores. Users can access a variety of products through a mobile application, add items to their virtual shopping cart, and complete the transaction online. Online stores often provide a range of products, including electronics, clothing, home goods, and more. The term 'go shop' emphasizes the ease and accessibility of the online shopping experience, allowing users to 'go' or navigate through the virtual store to make their purchases.   "),
                          leading: Icon(Icons.format_align_center),
                        ),
                        Bounceable(
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return GiffyDialog.image(
                                  Image.network(
                                    "https://cdn.dribbble.com/users/1179280/screenshots/5626747/dribbble.gif",
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    'Do You Want To EXIT!',
                                    style: GoogleFonts.openSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromARGB(255, 85, 84, 84),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'CANCEL'),
                                      child: const Text(
                                        'CANCEL',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.blueGrey,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseAuth.instance.signOut();

                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Error logging out: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Logout'),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.red[400],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            print("Logout");
                          },
                          child: ListTile(
                            title: Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                            leading: Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDialogWithImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.image(
          Image.network(
            "https://cdn.dribbble.com/users/102974/screenshots/2726841/head_bob.gif",
            height: 200,
            fit: BoxFit.cover,
          ),
          title: Text(
            'Change Profile!',
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'CANCEL'),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => selectImage(),
              child: const Text('CHANGE'),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        file = File(pickedImage.path);
        isImageSelected = true;
      });

      // await uploadImageToFirebase();
      // _updateDataToDatabase();
    }
    Navigator.pop(context, 'CHANGE');

    await uploadImageToFirebase();
    await updateImageToFirebase();
  }

  Future<void> uploadImageToFirebase() async {
    try {
      if (file != null) {
        final reference = FirebaseStorage.instance
            .ref()
            .child('user_profile_images/${DateTime.now()}.jpg');
        final uploadTask = reference.putFile(file!);

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        image = downloadUrl;

        print("Image uploaded to Firebase Storage: $downloadUrl");
      } else {
        print("No file selected for upload.");
      }
    } catch (e) {
      print("Error uploading image to Firebase Storage: $e");
    }
  }

  Future<void> updateImageToFirebase() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;

        // Update user data in Firestore with the new image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'ProfileImage': image});

        print("Profile image updated in Firestore successfully: $image");
      } else {
        print("No document found for profile image update.");
      }
    } catch (e) {
      print("Error updating profile image in Firestore: $e");
    }
  }
}
