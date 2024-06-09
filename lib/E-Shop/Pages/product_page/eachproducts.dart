import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_add_to_cart_button/flutter_add_to_cart_button.dart';
import 'package:go_shop/E-Shop/Api/apimodel.dart';
import 'package:go_shop/E-Shop/Pages/checkout_page.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin {
  List<Product> cartItems = [];
  List<Product> product = [];
  FirebaseAuth auth = FirebaseAuth.instance;

  late AnimationController _favoriteController;
  AddToCartButtonStateId stateId = AddToCartButtonStateId.idle;

  List<Product> productList = [];

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBuyNow = true;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    checkNetworkStatus();

    _favoriteController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
        setState(() {
          _showBuyNow = !_showBuyNow;
        });
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _favoriteController.dispose();
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

  @override
  Widget build(BuildContext context) {
    if (!hasInternet) {
      return NetworkErrorPage(onRefresh: checkNetworkStatus);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.6,
          elevation: 0,
          snap: true,
          floating: true,
          stretch: true,
          backgroundColor: Colors.grey.shade50,
          flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
              ],
              background: Image.network(
                widget.product.thumbnail,
                fit: BoxFit.cover,
              )),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(45),
              child: Transform.translate(
                offset: const Offset(0, 1),
                child: Container(
                  height: MediaQuery.of(context).size.height / 14,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                      child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_double_arrow_up_sharp,
                        color: Colors.grey.shade300,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.height / 30 - 27,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  )),
                ),
              )),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(10),
            scrollDirection: Axis.vertical,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      // ignore: sized_box_for_whitespace
                      Container(
                        height: 100,
                        width: 100,
                        child: IconButton(
                          splashRadius: 100,
                          iconSize: 100,
                          onPressed: () async {
                            try {
                              // Fetch the current favorite status of the product from Firebase
                              bool isProductFavorite =
                                  await fetchFavoriteStatusFromFirebase(
                                      widget.product);

                              setState(() {
                                // Toggle the favorite status
                                widget.product.isFavorite = !isProductFavorite;

                                if (widget.product.isFavorite) {
                                  addtofav(widget.product);

                                  // If the product is marked as a favorite, play the full-color animation
                                  _favoriteController.forward();
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.success(
                                      message:
                                          "${widget.product.title} Added to wishlist",
                                    ),
                                  );
                                } else {
                                  // If the product is not a favorite, play the reversed animation
                                  _favoriteController.reverse();
                                  removeFromFav(widget.product);
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.error(
                                      message:
                                          "${widget.product.title} Removed from wishlist",
                                    ),
                                  );
                                }
                              });
                            } catch (e) {
                              print("Error fetching favorite status: $e");
                            }
                          },
                          icon: Lottie.asset(
                            'asset/favorite.json',
                            controller: _favoriteController,
                            onLoaded: (composition) {
                              // Set the reverse parameter based on the initial favorite status
                              _favoriteController.duration =
                                  composition.duration;
                              _favoriteController
                                ..duration = composition.duration;
                              _favoriteController..forward();
                              if (!widget.product.isFavorite) {
                                _favoriteController.reverse();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 4,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50.0),
                      ),
                    ),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        aspectRatio: 2.0,
                      ),
                      items: widget.product.images.map((image) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: NetworkImage(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Text(
                    'Description :',
                    style: GoogleFonts.alegreyaSansSc(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 30 - 7,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(
                        widget.product.rating.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 80,
                  ),
                  Text(
                    'Discount  :${widget.product.discountPercentage}%',
                    style:
                        const TextStyle(color: Colors.blueGrey, fontSize: 16),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 80,
                  ),
                  Text(
                    "\$ ${widget.product.price}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 80,
                  ),
                 
MaterialButton(
  onPressed: () async {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: "${widget.product.title} Added to Cart",
      ),
    );
    await addToCart(widget.product);
  },
  minWidth: MediaQuery.of(context).size.width,
  height: MediaQuery.of(context).size.height / 20,
  color: Colors.black,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  elevation: 0,
  splashColor: Colors.amber[700],
  child: Center(
    child: Text(
      "ADD TO CART",
      style: GoogleFonts.alegreyaSansSc(
        fontSize: 25.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ),
),


                  SizedBox(
                    height: MediaQuery.of(context).size.height / 80,
                  ),
                  MaterialButton(

                    minWidth: MediaQuery.of(context).size.width,
                    onPressed: () {
                              Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: ProductOrderPage(product: widget.product),
                        ),
                      );
                    },
                    height: MediaQuery.of(context).size.height / 20,
                    elevation: 0,
                    splashColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.green[400],
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _animation.value,
                            child: Text(
                              _showBuyNow
                                  ? 'Buy Now'
                                  : "\$${widget.product.price}",
                              style: GoogleFonts.alegreyaSansSc(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                textStyle: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          )
        ])),
      ]),
    );
  }

  Future<void> addToCart(Product product) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;
        var currentCart = snapshot.docs.first['cart'] ?? [];
        var existingProductIndex = currentCart.indexWhere((item) =>
            item['title'] == product.title &&
            item['price'] == product.price &&
            item['thumbnail'] == product.thumbnail &&
            item['description'] == product.description);

        if (existingProductIndex != -1) {
          currentCart[existingProductIndex]['quantity'] += 1;
        } else {
          currentCart.add({
            'title': product.title,
            'price': product.price,
            'thumbnail': product.thumbnail,
            'quantity': 1,
            'description': product.description,
            'discountPercentage': product.discountPercentage,
            'rating': product.rating,
            'images': product.images,
          });
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'cart': currentCart});

        print("Product added to the cart in Firestore successfully.");
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> addtofav(Product product) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;

        var currentFav = snapshot.docs.first['favorite'] ?? [];

        var existingProductIndex = currentFav.indexWhere((item) =>
            item['title'] == product.title &&
            item['price'] == product.price &&
            item['thumbnail'] == product.thumbnail &&
            item['description'] == product.description);

        if (existingProductIndex != -1) {
        } else {
          currentFav.add({
            'title': product.title,
            'price': product.price,
            'thumbnail': product.thumbnail,
            'description': product.description,
            'discountPercentage': product.discountPercentage,
            'rating': product.rating,
            'images': product.images,
            'isFavorite': product.isFavorite
          });
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'favorite': currentFav});

        print("Product added to the favorite in Firestore successfully.");
      } else {
        print("No document found for adding the product to the favorite.");
      }
    } catch (e) {
      print("Error adding product to the favorite in Firestore: $e");
    }
  }

  Future<void> removeFromFav(Product product) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var documentId = snapshot.docs.first.id;

        var currentFav = snapshot.docs.first['favorite'] ?? [];

        var existingProductIndex = currentFav.indexWhere((item) =>
            item['title'] == product.title &&
            item['price'] == product.price &&
            item['thumbnail'] == product.thumbnail &&
            item['description'] == product.description);

        if (existingProductIndex != -1) {
          currentFav.removeAt(existingProductIndex);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(documentId)
              .update({'favorite': currentFav});

          print("Product removed from favorites in Firestore successfully.");
        } else {
          print("Product not found in favorites.");
        }
      } else {
        print("No document found for removing the product from favorites.");
      }
    } catch (e) {
      print("Error removing product from favorites in Firestore: $e");
    }
  }

  Future<bool> fetchFavoriteStatusFromFirebase(Product product) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: auth.currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var currentFav = snapshot.docs.first['favorite'] ?? [];

        // Find the product in the favorite list
        var productData = currentFav.firstWhere(
          (item) =>
              item['title'] == product.title &&
              item['price'] == product.price &&
              item['thumbnail'] == product.thumbnail &&
              item['description'] == product.description,
          orElse: () => null,
        );

        // Return true if the product is in the favorite list and is marked as favorite, false otherwise
        return productData != null && productData['isFavorite'] == true;
      } else {
        // No document found, default to false
        return false;
      }
    } catch (e) {
      print("Error fetching favorite status: $e");
      // Handle the error and default to false
      return false;
    }
  }
}
