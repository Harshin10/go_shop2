import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_shop/E-Shop/Api/api.dart';
import 'package:go_shop/E-Shop/Widgets/checkout_address_page.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProductOrderincart extends StatefulWidget {
  const ProductOrderincart({super.key});

  @override
  State<ProductOrderincart> createState() => _CartScreenState();
}

class _CartScreenState extends State<ProductOrderincart> {
  late Razorpay _razorpay;

  List<Product> fProducts = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  bool hasInternet = true;
double totalAmount = 0.0;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartData();
    checkNetworkStatus();
       
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }


  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment Success: ${response.paymentId}'),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment Error: ${response.code} - ${response.message}'),
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('External Wallet: ${response.walletName}'),
    ));
  }

  void _openCheckout() {
           double totalAmount = calculateTotalAmount();
    double deliveryCharge = totalAmount > 500 ? 0.0 : 4.0;
              double totalWithDelivery = totalAmount + deliveryCharge;
    var options = {
      'key': 'rzp_test_tetY2ITxhZi4vS',
      'amount': totalWithDelivery*100, // 10 Rupees (in paise)
      'name': 'Go Shop',
      'description': 'Payment for Services',
      'prefill': {
        'contact': '', // You can prefill with user's phone number if needed
        'email': '', // You can prefill with user's email if needed
      },
      'external': {
        'wallets': ['G-pay','paytm', 'phonepe', 'upi'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error initializing Razorpay: $e');
    }
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

  Future<void> fetchCartData() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var currentCart = snapshot.docs.first['cart'] ?? [];

        // Assuming each product in the cart has properties like title, price, thumbnail, etc.
        List<Product> fetchedProducts = currentCart.map<Product>((productData) {
          return Product(
            id: productData['id'] ?? 0,
            title: productData['title'] ?? '',
            description: productData['description'] ?? '',
            price: (productData['price'] ?? 0).toDouble(),
            discountPercentage:
                (productData['discountPercentage'] ?? 0).toDouble(),
            rating: (productData['rating'] ?? 0).toDouble(),
            stock: productData['stock'] ?? 0,
            brand: productData['brand'] ?? '',
            category: productData['category'] ?? '',
            thumbnail: productData['thumbnail'] ?? '',
            images: List<String>.from(productData['images'] ?? []),
            isFavorite: productData['isFavorite'] ?? false,
            quantity: productData['quantity'] ?? 0,
            totalamount: productData['totalamount'] ?? 0,
          );
        }).toList();

        setState(() {
          fProducts = fetchedProducts;
        });

        updateTotalPrice();
      } else {
        print("No document found for the user.");
      }
    } catch (e) {
      print("Error fetching cart data: $e");
    }
  }

  void updateTotalPrice() {
    double total = 0;
    for (Product product in fProducts) {
      total += (product.price);
    }
    setState(() {
      totalPrice = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasInternet) {
      return NetworkErrorPage(onRefresh: checkNetworkStatus);
    }
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: productList(),
          ),
          bottomBarTitle(),
        
        ],
      ),
    );
  }

  Widget productList() {
    return SingleChildScrollView(
      child: Column(
        children: [

          Column(
            children: fProducts.asMap().entries.map((entry) {
              final product = entry.value;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200]?.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 90,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                Colors.blueGrey, // Use a specific color for testing
                          ),
                          child: Image.network(
                            product.thumbnail,
                            fit: BoxFit.cover, // Use the image URL from the Product
                            //  width: 100,
                            // height: 90,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const SizedBox(height: 5),
                              Text(
                                "\$${product.price}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 23,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => decreaseItemQuantity(product),
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Color(0xFFEC6813),
                                    ),
                                  ),
                                  Text(
                                    '${product.quantity}', // Replace with actual quantity
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => increaseItemQuantity(product),
                                    icon: const Icon(Icons.add,
                                        color: Color(0xFFEC6813)),
                                  ),
                                ],
                              ),
                            ),
                      
                          ],
                        ),
                      ],
                    ),
                      Divider(),
                      
                    ListTile(
                      leading: Icon(Icons.palette_rounded),
                      title: Text("Product Name"),
                      subtitle: Text(product.title,),
                      
                    ),
                       ListTile(
                                            leading: Icon(Icons.dehaze_outlined),
                      
                      title: Text("Product Details"),
                      subtitle: Text(product.description),
                      
                    ),
                    ListTile(
                      leading: Icon(Icons.request_page),
                      title: Text(
                        "Total Amount",
                      ),
                    
                          subtitle:Text(
                          // totalAmount > 0
                          //     ? '\$${totalAmount.toStringAsFixed(2)}'
                          //     : '\$${product.price}',
                          // style: const TextStyle(
                          //   fontSize: 18,
                          //   fontWeight: FontWeight.w700,
                          // ),
                           product.quantity > 0 ?
                          '\$${product.price * product.quantity}': '${product.price}'
                        ),      
                                      
                                      
                                      
                      
                    ),
                 
                  ],
                ),
              );
            }).toList(),
          ),
          Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
  padding: EdgeInsets.all(20),
  margin: EdgeInsets.only(top: 15),
  decoration: BoxDecoration(
    color: Colors.grey.shade200,
    borderRadius: BorderRadius.circular(5.0),
  ),
  child: Column(
    children: [
    
   Row(
  children: [
    Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.card_giftcard_rounded),
          SizedBox(width: 10), // Spacer between icon and text
          Text("Order Date"),
        ],
      ),
    ),
    Spacer(),
    Text(DateFormat('dd-MM-yyyy').format(DateTime.now())),
  ],
),

 Row(
  children: [
    Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.departure_board_outlined),
          SizedBox(width: 10), // Spacer between icon and text
          Text("Delivery Date"),
        ],
      ),
    ),
    Spacer(),
    Text( DateFormat('dd-MM-yyyy').format(DateTime.now().add(Duration(days: 6))),
    ),
  ],
),
Column(
  children: [
    // Row for Delivery Charge
    Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(Icons.delivery_dining_outlined),
              SizedBox(width: 10), // Spacer between icon and text
              Text("Delivery Charge"),
            ],
          ),
        ),
        Spacer(),
  FutureBuilder<double>(
  future: fetchTotalAmount(),
  builder: (context, snapshot) {
 
      double totalAmount = snapshot.data ?? 0.0;
      double deliveryCharge = totalAmount > 500 ? 0.0 : 4.0;
      return Text(
        deliveryCharge == 4.0
            ? '\$ $deliveryCharge\n (Buy above 500)'
            : '\$ $deliveryCharge',
        textAlign: TextAlign.end,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: deliveryCharge > 0 ? Colors.black : Colors.green,
        ),
      );
    
  },
)

      ],
    ),
    // Row for Total Amount
    Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(Icons.price_check_outlined),
              SizedBox(width: 10), // Spacer between icon and text
              Text("Total Amount"),
            ],
          ),
        ),
        Spacer(),
        FutureBuilder<double>(
          future: fetchTotalAmount(),
          builder: (context, snapshot) {
         
              double totalAmount = snapshot.data ?? 0.0;
              double deliveryCharge = totalAmount > 500 ? 0.0 : 4.0;
              double totalWithDelivery = totalAmount + deliveryCharge;
              return Text(
                '\$ $totalWithDelivery',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              );
            
          },
        ),
      ],
    ),
  ],
)


    ],
  ),
),


                ),
                                   OrderDetails(),

                  bottomBarButton(),

        ],
      ),
    );
  }

  Widget bottomBarTitle() {
    double totalAmount = calculateTotalAmount();
    double deliveryCharge = totalAmount > 500 ? 0.0 : 4.0;
              double totalWithDelivery = totalAmount + deliveryCharge;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
          ),
          AnimatedSwitcherWrapper(
            totalAmount: totalWithDelivery,
            child: Text(
              "\$$totalAmount",
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Color(0xFFEC6813),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calculateTotalAmount() {
    double total = 0;
    for (Product product in fProducts) {
      total += (product.price * product.quantity);
    }
    return total;
  }

  Widget bottomBarButton() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
        child: MaterialButton(
  onPressed: () {
    _openCheckout();
  },
  padding: const EdgeInsets.all(20),
  color: Colors.green,
  splashColor: Colors.black,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20), // Adjust the value as needed
  ),
  child: Text(
    "Buy Now",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
  ),
)
      ),
    );
  }

  void decreaseItemQuantity(Product product) async {
    if (product.quantity > 1) {
      product.quantity--;
      updateTotalPrice();
      await updateCartQuantity(product);
    } else {
    }
  }

  // Increase quantity of a product in the cart
  void increaseItemQuantity(Product product) async {
    product.quantity++;
    updateTotalPrice();
    await updateCartQuantity(product);
  }

// Define the function to fetch the total amount asynchronously
Future<double> fetchTotalAmount() async {
 double totalAmount = calculateTotalAmount();
              // totalAmount: totalAmount,

        Column( 
          children: [
            Text(
              "\$$totalAmount",
             
            ),
          ],
        );
    
  return totalAmount;
}

  // Remove a product from the cart

  Future<void> updateCartQuantity(Product product) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;
        var currentCart = snapshot.docs.first['cart'] ?? [];

        // Find the product in the cart
        var existingProductIndex = currentCart.indexWhere((item) =>
            item['title'] == product.title &&
            item['price'] == product.price &&
            item['thumbnail'] == product.thumbnail &&
            item['description'] == product.description);

        if (existingProductIndex != -1) {
          // Update quantity in the cart
          currentCart[existingProductIndex]['quantity'] = product.quantity;

          // Update user data in Firestore with the updated cart
          await FirebaseFirestore.instance
              .collection('users')
              .doc(documentId)
              .update({'cart': currentCart});

          print("Quantity updated in Firestore successfully.");
        } else {
          print("Product not found in the cart.");
        }
      } else {
        print("No document found for the user.");
      }
    } catch (e) {
      print("Error updating quantity in Firestore: $e");
    }
  }
  Future<void> updateCartTotalamount(Product product) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;
        var currentCart = snapshot.docs.first['cart'] ?? [];

        // Find the product in the cart
        var existingProductIndex = currentCart.indexWhere((item) =>
            item['title'] == product.title &&
            item['price'] == product.price &&
            item['thumbnail'] == product.thumbnail &&
            item['description'] == product.description);

        if (existingProductIndex != -1) {
          // Update quantity in the cart
          currentCart[existingProductIndex]['totalamount'] = product.totalamount;

          // Update user data in Firestore with the updated cart
          await FirebaseFirestore.instance
              .collection('users')
              .doc(documentId)
              .update({'cart': currentCart});

          print("Quantity updated in Firestore successfully.");
        } else {
          print("Product not found in the cart.");
        }
      } else {
        print("No document found for the user.");
      }
    } catch (e) {
      print("Error updating quantity in Firestore: $e");
    }
  }
  void removeProductFromCart(Product product) async {
    fProducts.remove(product);
    updateTotalPrice();
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;
        var currentCart = snapshot.docs.first['cart'] ?? [];

        // Remove the product from the cart
        currentCart.removeWhere((item) =>
            item['title'] == product.title &&
            item['price'] == product.price &&
            item['thumbnail'] == product.thumbnail);

        // Update user data in Firestore with the updated cart
        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'cart': currentCart});

        print("Product removed from the cart in Firestore successfully.");
      } else {
        print("No document found for the user.");
      }
    } catch (e) {
      print("Error removing product from the cart in Firestore: $e");
    }
  }

}

class AnimatedSwitcherWrapper extends StatelessWidget {
  final Widget child;
  final double totalAmount;

  const AnimatedSwitcherWrapper({
    Key? key,
    required this.child,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Text(
        "\$$totalAmount",
        key: ValueKey<double>(totalAmount),
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w900,
          color: Color(0xFFEC6813),
        ),
      ),
    );
  }
}


