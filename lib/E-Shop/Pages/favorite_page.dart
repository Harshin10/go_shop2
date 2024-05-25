import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:go_shop/E-Shop/Api/api.dart';
import 'package:go_shop/E-Shop/Pages/product_page/eachproducts.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

// ignore: must_be_immutable
class FavoritesScreen extends StatefulWidget {
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> favProducts = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  bool hasInternet = true;

  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchfavData();
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

  Future<void> fetchfavData() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var currentFav = snapshot.docs.first['favorite'] ?? [];

        // Assuming each product in the cart has properties like title, price, thumbnail, etc.
        List<Product> fetchedProducts = currentFav.map<Product>((productData) {
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
          );
        }).toList();

        setState(() {
          favProducts = fetchedProducts;
        });
      } else {
        print("No document found for the user.");
      }
    } catch (e) {
      print("Error fetching cart data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasInternet) {
      return NetworkErrorPage(onRefresh: checkNetworkStatus);
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showDialogDelete(
                  context); // pass a product or null based on your requirements
            },
            icon: Icon(Icons.delete),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: isEmptyFav ? const EmptyFavorite() : favList(),
          ),
        ],
      ),
    );
  }

  Widget favList() {
    return SingleChildScrollView(
      child: Column(
        children: favProducts.asMap().entries.map((entry) {
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
                  // Container( height: 100,width: 100,
                  // child: Lottie.asset('asset/favroite.json'),)   ,

                  IconButton(
                      onPressed: () async {
                        removeProductFromFav(product);
                        setState(() {});
                      },
                      icon: Icon(Icons.delete_outline_outlined)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void removeProductFromFav(Product product) async {
    favProducts.remove(product);
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;
        var currentFav = snapshot.docs.first['favorite'] ?? [];

        // Remove the product from the cart
        currentFav.removeWhere((item) =>
            item['title'] == product.title &&
            item['price'] == product.price &&
            item['thumbnail'] == product.thumbnail);

        // Update user data in Firestore with the updated cart
        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'favorite': currentFav});

        print("Product removed from the favorite in Firestore successfully.");
      } else {
        print("No document found for the user.");
      }
    } catch (e) {
      print("Error removing product from the favorite in Firestore: $e");
    }
  }

  bool get isEmptyFav => favProducts.isEmpty;

  void showDialogDelete(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.image(
          Image.network(
            "https://cdn.dribbble.com/users/1199152/screenshots/15235682/media/334c20a45c845383b33fe3a97fecfb44.gif",
            height: 200,
            fit: BoxFit.cover,
          ),
          title: Text(
            'Delete All Product ?',
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
              onPressed: () {
                Navigator.pop(context, 'CANCEL');
                removeAllProductsFromFavorite();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void removeAllProductsFromFavorite() async {
    favProducts.clear();
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;

        // Delete the entire "favorite" collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update(
                {'favorite': []}); // Set the "favorite" field to an empty array
        setState(() {});
        print(
            "All products removed from the favorite list in Firestore successfully.");
      } else {
        print("No document found for the user.");
      }
    } catch (e) {
      print(
          "Error removing all products from the favorite list in Firestore: $e");
    }
  }
}

class EmptyFavorite extends StatelessWidget {
  const EmptyFavorite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://media2.giphy.com/media/LTFmLb6e88cPz2sjux/giphy.gif',
            ),
            SizedBox(height: 20), // Add spacing between image and text
            Text(
              'No items added to favorites',
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