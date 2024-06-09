import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:go_shop/E-Shop/Api/api.dart';
import 'package:go_shop/E-Shop/Api/apimodel.dart';
import 'package:go_shop/E-Shop/Pages/checkout_page1.dart';
import 'package:go_shop/E-Shop/Pages/product_page/eachproducts.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  List<Product> cartProducts = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  bool hasInternet = true;

  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartData();
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
          cartProducts = fetchedProducts;
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
    for (Product product in cartProducts) {
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
            child: isEmptyCart ? const EmptyCart() : cartList(),
          ),
          bottomBarTitle(),
          bottomBarButton(),
        ],
      ),
    );
  }

  Widget cartList() {
    return SingleChildScrollView(
      child: Column(
        children: cartProducts.asMap().entries.map((entry) {
          final product = entry.value;
          return Bounceable(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: ProductDetails(product: product),
                  ));
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200]?.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
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
                      IconButton(
                          onPressed: () {
                removeProductFromCart(product);
                          },
                          icon: Icon(Icons.delete_outline_outlined))
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget bottomBarTitle() {
    double totalAmount = calculateTotalAmount();
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

  double calculateTotalAmount() {
    double total = 0;
    for (Product product in cartProducts) {
      total += (product.price * product.quantity);
    }
    return total;
  }

  Widget bottomBarButton() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20), backgroundColor: Colors.green),
          onPressed: isEmptyCart ? null : () {

  Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: ProductOrderincart(),
                        ),
                      );

          },
          child: const Text(
            "Buy Now",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }

  void decreaseItemQuantity(Product product) async {
    if (product.quantity > 1) {
      product.quantity--;
      updateTotalPrice();
      await updateCartQuantity(product);
    } else {
      removeProductFromCart(product);
    }
  }

  // Increase quantity of a product in the cart
  void increaseItemQuantity(Product product) async {
    product.quantity++;
    updateTotalPrice();
    await updateCartQuantity(product);
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
    cartProducts.remove(product);
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

  bool get isEmptyCart => cartProducts.isEmpty;


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


class EmptyCart extends StatelessWidget {
  const EmptyCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn.dribbble.com/users/2046015/screenshots/4591856/first_white_girl_drbl.gif',
            ),
            SizedBox(height: 20), // Add spacing between image and text
            Text(
              'No items added to cart',
              style: GoogleFonts.alegreyaSansSc(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                                                          color: Colors.black,
            
                        fontStyle: FontStyle.italic,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}