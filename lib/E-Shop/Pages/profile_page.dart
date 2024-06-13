import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_loader/easy_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.container);
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this._container) : super(UserState()) {
    _initialize();
  }

  final ProviderContainer _container;

  Future<void> _initialize() async {
    final auth = _container.read(authProvider);
    final user = auth.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        state = state.copyWith(
          name: userData['username'] ?? '',
          email: userData['email'] ?? '',
          address: userData['Address'] ?? '',
          image: userData['ProfileImage'] ?? '',
          countryCode: userData['countrycode'] ?? '',
          mobile: userData['Phone Number'] ?? '',
        );
      }
    }
  }

  Future<void> updateData(
      String name, String address, String mobile, String image) async {
    final auth = _container.read(authProvider);
    final user = auth.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final documentId = snapshot.docs.first.id;

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(documentId)
              .update({
            'username': name,
            'Address': address,
            'ProfileImage': image,
            'Phone Number': mobile,
          });

          state = state.copyWith(
              name: name, address: address, mobile: mobile, image: image);
        } catch (e) {
          print('Failed to update user data: $e');
        }
      }
    }
  }
}

class UserState {
  final String name;
  final String email;
  final String address;
  final String image;
  final String countryCode;
  final String mobile;

  UserState({
    this.name = '',
    this.email = '',
    this.address = '',
    this.image = '',
    this.countryCode = '',
    this.mobile = '',
  });

  UserState copyWith({
    String? name,
    String? email,
    String? address,
    String? image,
    String? countryCode,
    String? mobile,
  }) {
    return UserState(
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      image: image ?? this.image,
      countryCode: countryCode ?? this.countryCode,
      mobile: mobile ?? this.mobile,
    );
  }
}

class Profile extends ConsumerStatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController numController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isEditingName = false;
  bool isEditingAddress = false;
  bool isEditingNum = false;
  bool isLoadingImage = false;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    nameController.text = userState.name;
    addressController.text = userState.address;
    numController.text = userState.mobile;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            SizedBox(
                height: 250,
                width: double.infinity,
                child: _buildProfileImage(context, userState)),
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
                                  child: _buildProfileImage(context, userState),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.person),
                                        title: Text(
                                          userState.name,
                                          style: GoogleFonts.alegreyaSansSc(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: <Widget>[
                                Divider(),
                                _buildListTile(
                                  context: context,
                                  formKey: formKey,
                                  isEditing: isEditingName,
                                  controller: nameController,
                                  title: "Name",
                                  subtitle: userState.name,
                                  icon: Icons.person,
                                  onSave: () {
                                    setState(() {
                                      isEditingName = false;
                                      isEditingNum = false;
                                      isEditingAddress = false;
                                    });

                                    if (nameController.text.isNotEmpty) {
                                      ref
                                          .read(userProvider.notifier)
                                          .updateData(
                                            nameController.text,
                                            addressController.text,
                                            numController.text,
                                            userState.image,
                                          );
                                    }
                                  },
                                  onEdit: () {
                                    setState(() {
                                      isEditingName = true;
                                    });
                                  },
                                ),
                                _buildListTile(
                                  context: context,
                                  formKey: formKey,
                                  isEditing: isEditingNum,
                                  controller: numController,
                                  title: "Mobile Number",
                                  subtitle:
                                      '${userState.countryCode} ${userState.mobile}',
                                  icon: Icons.phone_iphone_outlined,
                                  onSave: () {
                                    setState(() {
                                      isEditingName = false;
                                      isEditingNum = false;
                                      isEditingAddress = false;
                                    });

                                    if (numController.text.isNotEmpty) {
                                      ref
                                          .read(userProvider.notifier)
                                          .updateData(
                                            nameController.text,
                                            addressController.text,
                                            numController.text,
                                            userState.image,
                                          );
                                    }
                                  },
                                  onEdit: () {
                                    setState(() {
                                      isEditingNum = true;
                                    });
                                  },
                                ),
                                ListTile(
                                  title: Text("Email"),
                                  subtitle: Text(userState.email),
                                  leading: Icon(Icons.email),
                                ),
                                _buildListTile(
                                  context: context,
                                  formKey: formKey,
                                  isEditing: isEditingAddress,
                                  controller: addressController,
                                  title: "Address",
                                  subtitle: userState.address,
                                  icon: Icons.add_home_work_outlined,
                                  onSave: () async {
                                    setState(() {
                                      isEditingName = false;
                                      isEditingNum = false;
                                      isEditingAddress = false;
                                    });

                                    if (addressController.text.isNotEmpty ) {
                                      ref
                                          .read(userProvider.notifier)
                                          .updateData(
                                            nameController.text,
                                            addressController.text,
                                            numController.text,
                                            userState.image,
                                          );
                                    }
                                  },
                                  onEdit: () {
                                    setState(() {
                                      isEditingAddress = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                              "'Go shop' typically refers to an online shopping platform or service where consumers can browse and purchase products over the internet. It is a convenient way for people to shop for a wide range of items, including clothing, electronics, household goods, and more, from the comfort of their own homes."),
                          leading: Icon(Icons.language),
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

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Change Image'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  setState(() {
                    isLoadingImage = true;
                  });

                  final user = ref.read(authProvider).currentUser;
                  final storageRef = FirebaseStorage.instance
                      .ref()
                      .child('profile_images')
                      .child(user!.uid)
                      .child('profile.jpg');

                  await storageRef.putFile(File(pickedFile.path));
                  final downloadUrl = await storageRef.getDownloadURL();

                  ref.read(userProvider.notifier).updateData(
                        ref.read(userProvider).name,
                        ref.read(userProvider).address,
                        ref.read(userProvider).mobile,
                        downloadUrl,
                      );

                  setState(() {
                    isLoadingImage = false;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Image'),
              onTap: () async {
                Navigator.pop(context);
                await _removeImage();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeImage() async {
    final user = ref.read(authProvider).currentUser;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child(user!.uid)
        .child('profile.jpg');

    await storageRef.delete();

    ref.read(userProvider.notifier).updateData(
          ref.read(userProvider).name,
          ref.read(userProvider).address,
          ref.read(userProvider).mobile,
          '',
        );
  }

  ListTile _buildListTile({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required bool isEditing,
    required TextEditingController controller,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onSave,
    required VoidCallback onEdit,
  }) {
    return ListTile(
      title: isEditing
          ? TextFormField(
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $title';
                }
                return null;
              },
            )
          : Text(subtitle),
      leading: Icon(icon),
      trailing: IconButton(
        icon: Icon(isEditing ? Icons.save : Icons.edit),
        onPressed: isEditing ? onSave : onEdit,
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, UserState userState) {
    return Stack(
      fit: StackFit.expand,
      children: [
        userState.image.isEmpty
            ? Bounceable(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    "asset/man2.png",
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Bounceable(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    userState.image,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        if (isLoadingImage)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                    color: Colors.white,
                    child: EasyLoader(image: AssetImage("asset/logo.png"))),
              ),
            ),
          ),
      ],
    );
  }
}
