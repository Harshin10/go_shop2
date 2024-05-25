import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_shop/E-Shop/Api/api.dart';
import 'package:go_shop/E-Shop/Pages/address_selection_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class OrderDetails extends StatefulWidget {
 


  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
Map<String, dynamic>? _selectedAddressData;

  String? name = '';
  String? email = '';
  String? address = '';
  String? countrycode = '';
  String? mobile = '';
  String? image = '';
 double totalPrice = 0.0;
  FirebaseAuth auth = FirebaseAuth.instance;
   List<Product> cartProducts = [];

   @override
  void initState() {
    super.initState();
  _getDataFromDatabase();
  }

  Widget build(BuildContext context) {
    return Column(
      children: [

        addressselect(context),
      ],
    );
  }

  Padding addressselect(BuildContext context) {
    return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                            padding: EdgeInsets.all(20),
                            margin: EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                              color:  Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child:Column(children: [ 
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                   Text(
                                                            "Delevery Address",
                                                             style: GoogleFonts.alegreyaSansSc(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                                                          ),
                                                     
                                                          Container(
                                                         
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Colors.white,
                                                              border: Border.all(
                                                                          color: Colors.black, // Adjust the border color as needed
                                                                          width: 1.0, // Adjust the border width as needed
                                                              ),
                                                            ),
                                                            child: TextButton(
                                                              onPressed: () async{
                                         Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: ProductaddrselectPage())).then((selectedAddress) {
  if (selectedAddress != null) {
    _handleSelectedAddress(selectedAddress);
  }
});


// Use the selectedAddress here


                                                              },
                                                              child: Text("Change",
                                                              ),
                                                            ),
                                                          ),
                                  ],
                                ),
                                
                    
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectedAddressData != null && _selectedAddressData!.isNotEmpty
              ? Column(
                  children: [
                    // Text(
                    //   _selectedAddressData!['name'],
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                     ListTile(
                                      title: Text("Name"),
                                      subtitle:Text(_selectedAddressData!['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),),
                                      leading: Icon(Icons.person),
                                     
                                    ),
                                     ListTile(
                                      title: Text("Mobile Number"),
                                      subtitle:Text(_selectedAddressData!['countryCode']),
                                      leading: Icon(Icons.phone_iphone_outlined),
                                     
                                    ),
                                     
                
                    ListTile(
                                      title: Text("Email"),
                                      subtitle:Text(_selectedAddressData!['email']),
                                      leading: Icon(Icons.email),
                                     
                                    ),
                 ListTile(
                                      title: Text("Address"),
                                      subtitle:Text(_selectedAddressData!['address']),
                                      leading: Icon(Icons.add_home_work_outlined),
                                     
                                    ),
             
                  ],
                )
              : 
Column(
                               children: [

                                 ListTile(
                                      title: Text("Name"),
                                      subtitle:Text(name!),
                                      leading: Icon(Icons.person),
                                     
                                    ),
                                     ListTile(
                                  leading: Icon(Icons.phone_iphone_outlined),
                                  title: Text(
                                    "Mobile Number",
                                  ),
                                  subtitle:Text('${countrycode!}  ${mobile!}'),
      
      
      
                                  
                                ),
                                ListTile(
                                  title: Text("Email"),
                                  subtitle: Text(email!),
                                  leading: Icon(Icons.email),
                                ),
                                ListTile(
                                  title: Text("Address"),
                                  subtitle:Text(address!),
                                  leading: Icon(Icons.add_home_work_outlined),
                                 
                                ),
                               ],
                             ),  
   
        ],
      ),

                              
                   


//  addressselect(context),
//         // Display the selected address
//         Text(
//           'Selected Address: ${widget.selectedAddress ?? ""}',
//           style: TextStyle(fontSize: 18),
//         ),







                            ],),
                            ),
                );
  }
   
    
   Future<void> _getDataFromDatabase() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userData = snapshot.docs.first.data();
        setState(() {
          name = userData['username'] ?? '';
          email = userData['email'] ?? '';
          address = userData['Address'] ?? '';
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
  
     double calculateTotalAmount() {
    double total = 0;
    for (Product product in cartProducts) {
      total += (product.price * product.quantity);
    }
    return total;
  }
  void decreaseItemQuantity(Product product) async {
    if (product.quantity > 1) {
      product.quantity--;
      updateTotalPrice();
   
    } else {
    }
  }

  // Increase quantity of a product in the cart
  void increaseItemQuantity(Product product) async {
    product.quantity++;
    updateTotalPrice();
   
  }

  void updateTotalPrice() {
    double total = 0;
    for (Product product in cartProducts) {
      total += (product.price);
    }
    setState(() {
      totalPrice = total;
    });
  }
  
void _handleSelectedAddress(Map<String, dynamic> selectedAddress) {
  setState(() {
    _selectedAddressData = selectedAddress;
  });
}


  //  void calculateTotalAmount() {
  //   setState(() {
  //     totalAmount = quantity * widget.product.price;
  //   });
  // }
}
