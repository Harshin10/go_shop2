import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_shop/E-Shop/Api/api.dart'; // Import your Product model here
import 'package:go_shop/E-Shop/Pages/cart_page.dart';
import 'package:go_shop/E-Shop/Widgets/checkout_address_page.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProductOrderPage extends StatefulWidget {
  const ProductOrderPage({Key? key, required this.product}) : super(key: key);

  final Product product;

  @override
  State<ProductOrderPage> createState() => _ProductOrderPageState();
}

class _ProductOrderPageState extends State<ProductOrderPage> {
    late Razorpay _razorpay;

  int quantity = 1;
double totalAmount = 0.0;
 String? name = '';
  String? email = '';
  String? address = '';
  String? countrycode = '';
  String? mobile = '';
  String? image = '';

  FirebaseAuth auth = FirebaseAuth.instance;
   @override
  void initState() {
    super.initState();
    checkNetworkStatus();
            calculateTotalAmount();
bottomBarTitle();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
   
  bool hasInternet = true;


  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
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
    var options = {
      'key': 'rzp_test_tetY2ITxhZi4vS',
      'amount': totalAmount* 100, // 10 Rupees (in paise)
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

  @override
  Widget build(BuildContext context) {
     if (!hasInternet) {
      return NetworkErrorPage(onRefresh: checkNetworkStatus);
    }
    return Scaffold(
     
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     SizedBox(height: 30,),
            
                     
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color:Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                           Text(
                              "Product Details",
                               style: GoogleFonts.alegreyaSansSc(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          Row(
                            children: [
                              Container(
                               width: 100,
                            height: 90,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blueGrey, // Use a specific color for testing
                                ),
                                child: Image.network(
                                  widget.product.thumbnail,
                                  fit: BoxFit.cover, 
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "\$${widget.product.price}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 23,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                      onPressed: () => decreaseQuantity(),
                                      icon: const Icon(
                                        Icons.remove,
                                        color: Color(0xFFEC6813),
                                      ),
                                    ),
                                    Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => increaseQuantity(),
                                      icon: const Icon(Icons.add, color: Color(0xFFEC6813)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(),
              
                          ListTile(
                            leading: Icon(Icons.palette_rounded),
                            title: Text("Product Name"),
                            subtitle: Text(widget.product.title,),
                            
                          ),
                             ListTile(
                                                  leading: Icon(Icons.dehaze_outlined),
              
                            title: Text("Product Details"),
                            subtitle: Text(widget.product.description),
                            
                          ),
                          ListTile(
                            leading: Icon(Icons.request_page),
                            title: Text(
                              "Total Amount",
                            ),
                          
                                subtitle:Text(
                                totalAmount > 0
                                    ? '\$${totalAmount.toStringAsFixed(2)}'
                                    : '\$${widget.product.price}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),      
                                            
                                            
                                            
                            
                          ),
                       
                        ],
                      ),
                    ),
                   OrderDetails(),
                        
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
                Text(DateFormat('dd-MM-yyyy').format(DateTime.now()),style: TextStyle(
                   fontSize: 15,
                fontWeight: FontWeight.w700,
                ),),
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
                Text( DateFormat('dd-MM-yyyy',).format(DateTime.now().add(Duration(days: 6))),
                style: TextStyle( fontSize: 15,
                fontWeight: FontWeight.w700,),
                ),
              ],
            ),
            
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
              Text(textAlign: TextAlign.end,
              totalAmount > 500
                ? '\$ 0.0'
                : '\$4\n(buy above 500)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                // decoration: totalAmount > 500 ? TextDecoration.none : TextDecoration.lineThrough,
                color: totalAmount > 500 ? Colors.green : Colors.black,
              ),
            ),
            
             
             
              ],
            ),
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
                Text(  totalAmount > 0
                                    ? '\$${totalAmount+= totalAmount > 500
                ? 0
                : 4}'
                                    : '\$${widget.product.price+ totalAmount > 500
                ? 0
                : 4 }',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),),
             
            //  .toStringAsFixed(2)
              ],
            ),
                ],
              ),
            ),
            
            
                      ) ,
                      bottomBarButton()
                  ],
                ),
              ),
            ),
          ),
          bottomBarTitle(),

        ],
      ),
    );
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

  void increaseQuantity() {
    setState(() {
      quantity++;
        calculateTotalAmount();
    });
  }

  void decreaseQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
          calculateTotalAmount();
      }
      else {
        Navigator.pop(context);
    }
    });
  }
   void calculateTotalAmount() {
    setState(() {
      totalAmount = quantity * widget.product.price;
    });
  }
   Widget bottomBarTitle() {
 
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
            totalAmount: totalAmount,
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
}
