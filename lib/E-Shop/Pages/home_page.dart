import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_shop/E-Shop/Api/apimodel.dart';
import 'package:go_shop/E-Shop/Pages/cart_page.dart';
import 'package:go_shop/E-Shop/Pages/favorite_page.dart';
import 'package:go_shop/E-Shop/Pages/login_page.dart';
import 'package:go_shop/E-Shop/Pages/product_page/category_home_page.dart';
import 'package:go_shop/E-Shop/Widgets/search.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:go_shop/E-Shop/provider/productprovider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_loader/easy_loader.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter/material.dart';
import 'package:go_shop/E-Shop/Api/api.dart';
import 'package:go_shop/E-Shop/Pages/product_page/product_section.dart';
import 'package:go_shop/E-Shop/Pages/product_page/eachproducts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//     API2 api2 = API2();

//   final SearchAPI searchController = SearchAPI();
//   List<Product> items = [];
//   List<Product> cartItems = [];
//   List<String> existingTitles = [];
//   bool isLoading = false;
//   List<Product> allProducts = []; // Your list of all products
//   List<Product> searchResults = [];
//   final TextEditingController textController = TextEditingController();
  late final List<String> imageList = [
    "https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://media.istockphoto.com/id/1395058279/photo/couple-at-home-making-a-reservation-online-using-their-laptop.webp?b=1&s=170667a&w=0&k=20&c=Cqhsw8Alwh_DOL7Pr5RwgO12HlehlQaUJ6z-ZEHe3Hc=",
    "https://images.unsplash.com/photo-1571210862729-78a52d3779a2?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGtpZHN8ZW58MHx8MHx8fDA%3D",
    "https://plus.unsplash.com/premium_photo-1663126299834-b8f22641f3c0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTd8fGtpZHN8ZW58MHx8MHx8fDA%3D",
    "https://media.istockphoto.com/id/526019537/photo/hangers-with-clothes.webp?s=170667a&w=0&k=20&c=vBcPbpO8mI-sVcWZZ3WDhwrPefwrBO0MyvhKY3edkyA=",
    "https://images.unsplash.com/photo-1512201078372-9c6b2a0d528a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDV8fHxlbnwwfHx8fHw%3D"
  ];


//   bool hasInternet = true;

//   List<String> products = [];
//   Future<void> checkNetworkStatus() async {
//     var connectivityResult = await Connectivity().checkConnectivity();

//     if (connectivityResult == ConnectivityResult.none) {
//       setState(() {
//         hasInternet = false;
//       });
//     } else {
//       setState(() {
//         hasInternet = true;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     checkNetworkStatus();
//   }

//   @override
//   build(BuildContext context) {
//     if (!hasInternet) {
//       return NetworkErrorPage(onRefresh: checkNetworkStatus);
//     }
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: FutureBuilder<List<Product>>(
//           future: api2.fetchData(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: EasyLoader(
//                   image: AssetImage('asset/logo.png'),
//                 ),
//               );
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text('No data available'));
//             } else {
//               // Use the fetched data here
//               List<Product>? products = snapshot.data;

//               return Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   homepage(context, products),
//                   buildFloatingSearchBar(searchController)
//                 ],
//               );
//             }
//           }),
//     );
//   }
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInternet = ref.watch(networkProvider);
    final products = ref.watch(productProvider);

    if (!hasInternet) {
      return NetworkErrorPage(onRefresh: () {
        ref.read(networkProvider.notifier).checkNetworkStatus();
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: products.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                homepage(context, products),
                // buildFloatingSearchBar( controller),
              ],
            ),
    );
  }

  SingleChildScrollView homepage(
      BuildContext context, List<Product>? products) {
    return SingleChildScrollView(
        child: Column(
      children: [
        FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: Container(
              height: MediaQuery.of(context).size.width * 1.2,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://images.unsplash.com/photo-1489710437720-ebb67ec84dd2?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                ),
                fit: BoxFit.cover,
              )),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            colors: [
                          Colors.black.withOpacity(.8),
                          Colors.black.withOpacity(.2),
                        ])),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.all(30)),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FadeInUp(
                                  duration: const Duration(milliseconds: 1500),
                                  child: Text(
                                    "GO SHOP",
                                    style: GoogleFonts.alegreyaSansSc(
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.bold,
                                      textStyle:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )),
                              const Spacer(),
                              FadeInUp(
                                  duration: const Duration(milliseconds: 1200),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.fade,
                                          child: FavoritesScreen(),
                                        ),
                                      );
                                    },
                                  )),
                              FadeInUp(
                                  duration: const Duration(milliseconds: 1300),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.fade,
                                          child: CartScreen(),
                                        ),
                                      );
                                    },
                                  )),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        FadeInUp(
            duration: const Duration(milliseconds: 1400),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.width * 0.7,
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
                      items: imageList
                          .map((e) => ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    CachedNetworkImage(
                                      imageUrl: e,
                                      width: 1050,
                                      height: 350,
                                      fit: BoxFit.cover,
                                    )
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Categories",
                        style: GoogleFonts.alegreyaSansSc(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      MaterialButton(
                        splashColor: Colors.black,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoryHome()),
                          );
                        },
                        color: Colors.amber[100],
                        child:Text(
                                'All',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                      makeCategory(context, category: 'Clothes', image: 'https://images.unsplash.com/photo-1514970733252-4e0b0ef2e184'),
makeCategory(context, category: 'Shoes', image: 'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb'),
makeCategory(context, category: 'Accessories', image: 'https://images.unsplash.com/photo-1512201078372-9c6b2a0d528a'),
makeCategory(context, category: 'Home', image: 'https://images.unsplash.com/photo-1489710437720-ebb67ec84dd2'),
makeCategory(context, category: 'Beauty', image: 'https://images.unsplash.com/photo-1512446811060-3ea50e01e515'),

                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                          "New Arrival",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 2000),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products!.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetails(
                                  product: products[index],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: 1.8,
                                  child: CachedNetworkImage(
                                    imageUrl: products![index].thumbnail,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    products[index].title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    '\$${products![index].price}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                ],
              ),
            ));
       })) ],
    )))]));
  }

  // FutureBuilder<List<Product>> apiproducts() {
  //   return FutureBuilder<List<Product>>(
  //     future: api2.fetchData(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(
  //           child: EasyLoader(
  //             image: AssetImage('asset/logo.png'),
  //           ),
  //         );
  //       } else if (snapshot.hasError) {
  //         return Center(
  //           child: Text('Error: ${snapshot.error}'),
  //         );
  //       } else {
  //         List<Product> items = snapshot.data ?? [];
  //         return ListView(
  //           physics: const BouncingScrollPhysics(),
  //           semanticChildCount: items.length,
  //           shrinkWrap: true,
  //           children: items.map((Product product) {
  //             return Padding(
  //               padding: const EdgeInsets.all(20),
  //               child: Container(
  //                 width: double.infinity,
  //                 margin: const EdgeInsets.symmetric(vertical: 10),
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(30),
  //                 ),
  //                 child: Bounceable(
  //                   onTap: () {
  //                     Navigator.push(
  //                       context,
  //                       PageTransition(
  //                         type: PageTransitionType.fade,
  //                         child: ProductDetails(product: product),
  //                       ),
  //                     );
  //                   },
  //                   child: Stack(
  //                     children: [
  //                       Container(
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(10),
  //                           border: Border.all(
  //                             color: Color(
  //                                 0xFF9E9E9E), // Adjust the border color as needed
  //                             width: 1.0, // Adjust the border width as needed
  //                           ),
  //                         ),
  //                         child: Row(
  //                           children: [
  //                             // Displaying the product thumbnail image
  //                             ClipRRect(
  //                               borderRadius: BorderRadius.circular(10),
  //                               child: Image.network(
  //                                 product.thumbnail,
  //                                 fit: BoxFit.cover,
  //                                 height:
  //                                     MediaQuery.of(context).size.height * 0.15,
  //                                 width:
  //                                     MediaQuery.of(context).size.width * 0.3,
  //                                 loadingBuilder: (BuildContext context,
  //                                     Widget child,
  //                                     ImageChunkEvent? loadingProgress) {
  //                                   if (loadingProgress == null) {
  //                                     return child;
  //                                   } else {
  //                                     return Center(
  //                                       child: CircularProgressIndicator(
  //                                         value: loadingProgress
  //                                                     .expectedTotalBytes !=
  //                                                 null
  //                                             ? loadingProgress
  //                                                     .cumulativeBytesLoaded /
  //                                                 loadingProgress
  //                                                     .expectedTotalBytes!
  //                                             : null,
  //                                       ),
  //                                     );
  //                                   }
  //                                 },
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               width:
  //                                   MediaQuery.of(context).size.height * 0.1 -
  //                                       70,
  //                             ),
  //                             // Displaying product details in a Column
  //                             Column(
  //                               children: [
  //                                 // Displaying product title
  //                                 Text(
  //                                   product.title.length > 9
  //                                       ? '${product.title.substring(0, 9)}...'
  //                                       : product.title,
  //                                   style: const TextStyle(
  //                                     fontSize: 25,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                                 // Displaying product brand
  //                                 Text(
  //                                   "(${product.brand.length > 10 ? '${product.brand.substring(0, 10)}...' : product.brand})",
  //                                   style: const TextStyle(
  //                                     color: Color.fromARGB(255, 110, 110, 108),
  //                                     fontSize: 15,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                                 // Displaying product rating
  //                                 Row(
  //                                   children: [
  //                                     const Icon(Icons.star,
  //                                         color: Colors.amber),
  //                                     Text(
  //                                       product.rating.toString(),
  //                                       style: const TextStyle(fontSize: 16),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 // Displaying product price
  //                                 Text(
  //                                   "\$ ${product.price}",
  //                                   style: const TextStyle(
  //                                     fontWeight: FontWeight.w900,
  //                                     fontSize: 23,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       // Details on the right side
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           }).toList(),
  //         );
  //       }
  //     },
  //   );
  // }

 Widget makeCategory(context,{required String category, required String image}) {
    return AspectRatio(
      aspectRatio: 2.5 / 2,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: CategoryHome(),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: CachedNetworkImageProvider(image),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

 Widget buildFloatingSearchBar(SearchAPI controller) {
  return FloatingSearchBar(
    showCursor: true,
    hint: 'Search...',
    onQueryChanged: (query) {
      controller.fetchProducts(query);
    },
    onSubmitted: (query) {
      controller.fetchProducts(query);
    },
    clearQueryOnClose: true,
    transition: CircularFloatingSearchBarTransition(),
    actions: [
      FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
          icon: const Icon(Icons.maps_home_work_outlined),
          onPressed: () {},
        ),
      ),
      FloatingSearchBarAction.searchToClear(
        showIfClosed: false,
      ),
    ],
    builder: (context, transition) {
      return StreamBuilder<List<Product>>(
        stream: controller.productStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  child: Lottie.asset('asset/lottie1.json'),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            List<Product> products = snapshot.data ?? [];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Material(
                elevation: 4.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isLoading)
                      Center(child: Lottie.asset('asset/lottie1.json')),
                    if (controller.hasError)
                      Center(child: Text(controller.errorMessage)),
                    if (!controller.isLoading && !controller.hasError)
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Bounceable(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetails(product: product),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text(product.title),
                              // Add other details as needed
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }
        },
      );
    },
  );
}

}
