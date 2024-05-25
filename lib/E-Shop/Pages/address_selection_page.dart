import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductaddrselectPage extends StatefulWidget {
  @override
  _ProductaddressPageState createState() => _ProductaddressPageState();
}

class _ProductaddressPageState extends State<ProductaddrselectPage> {
  late String _selectedAddress; // Selected address
  List<Map<String, dynamic>> addresses = []; // List of addresses

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

Future<void> _fetchAddresses() async {
  try {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var currentAddress = snapshot.docs.first['newaddress'];
      if (currentAddress != null) {
        setState(() {
          addresses = List<Map<String, dynamic>>.from(currentAddress);
          _selectedAddress = addresses[0]['name']; // Select the first address by default
        });
      } else {
        print("No Added New Address");
      }
    } else {
      print("No documents found for the current user's email.");
    }
  } catch (e) {
    print("Error fetching addresses: $e");
  }
}


  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: addresses.isEmpty
            ? Text('No Added Address')
            : ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  var address = addresses[index];
                  return
            
               RadioListTile(
  title: Container(
    padding: EdgeInsets.all(10),
    margin: EdgeInsets.only(top: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5.0),
      border: Border.all(
        width: 2.0,
        color: _selectedAddress == address['name'] ? Colors.blue : Colors.grey, // Border color based on selection
      ),
      color: _selectedAddress == address['name'] ? Colors.blue.withOpacity(0.1) : Colors.transparent, // Container color based on selection
    ),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft, // Align text to the left
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${address['name']}"),
              Text("Mobile Number: ${address['countryCode']}"),
              Text("Email: ${address['email']}"),
              Text("Address: ${address['address']}"),
            ],
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            onPressed: () async {
              await removeAddress(index);
              setState(() {});
            },
            icon: Icon(Icons.delete_outline_outlined),
          ),
        ),
      ],
    ),
  ),
  value: address['name'],
  groupValue: _selectedAddress,
  activeColor: Colors.blue, // Color of the selected radio button
  onChanged: (value) {
    setState(() {
      _selectedAddress = value as String;
    });
  },
);


  })
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.0),
        child: MaterialButton(
          height: 50,
          color: Colors.blue,
          splashColor: Colors.black,
           shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),onPressed: () {
            if (_selectedAddress.isNotEmpty) {
              var selectedAddress = addresses
                  .firstWhere((element) => element['name'] == _selectedAddress);
              Navigator.of(context).pop(selectedAddress);
            }
          },
          child: Text('Next'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Address'),
                content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length < 3) {
                              return 'Please enter a name with at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          controller: countryCodeController,
                          decoration: InputDecoration(labelText: 'Mobile Number'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a mobile number';
                            }
                            RegExp regExp = RegExp(r'^\+\d{1,3}\s\d{6,}$');
                            if (!regExp.hasMatch(value)) {
                              return '(eg:+91 **********) Please enter \n mobile number with country code';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            RegExp regExp = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(labelText: 'Address'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an address';
                            }
                            if (value.length < 5) {
                              return 'Address must be at least 5 characters long';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           ElevatedButton(
            onPressed: ()  {
          
          Navigator.of(context).pop();
         
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
          await addAddresses();
          Navigator.of(context).pop();
          setState(() {
            _fetchAddresses();
            // _selectedAddress = addresses.last['name']; // Set selected address to the last added address
          });
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),


                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> addAddresses() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;
        var currentAddress = List<Map<String, dynamic>>.from(
            snapshot.docs.first['newaddress'] ?? []);

        var newAddress = {
          'name': nameController.text,
          'countryCode': countryCodeController.text,
          'email': emailController.text,
          'address': addressController.text,
        };

        currentAddress.add(newAddress);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'newaddress': currentAddress});

        print("Address added to Firestore successfully.");
      }
      setState(() {
       _fetchAddresses();
      });
    } catch (e) {
      print("Error adding address to Firestore: $e");
    }
  }
    Future<void> removeAddress(int index) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;
        var currentAddress = List<Map<String, dynamic>>.from(
            snapshot.docs.first['newaddress'] ?? []);

        if (index >= 0 && index < currentAddress.length) {
          currentAddress.removeAt(index);
          print("Address removed from Firestore successfully.");
          setState(() {
            _fetchAddresses();
          });
        } else {
          print("Invalid index for address deletion.");
          return;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'newaddress': currentAddress});
      }
    } catch (e) {
      print("Error removing address from Firestore: $e");
    }
  }
}
