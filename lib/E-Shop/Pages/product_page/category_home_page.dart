import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:go_shop/E-Shop/Api/api.dart';
import 'package:go_shop/E-Shop/Api/apimodel.dart';
import 'package:go_shop/E-Shop/Pages/product_page/product_section.dart';
import 'package:go_shop/E-Shop/Widgets/network.dart';
import 'package:go_shop/E-Shop/provider/productprovider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class CategoryHome extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsyncValue = ref.watch(APIService.categoryProvider);
   List imageUrl =["https://plus.unsplash.com/premium_photo-1673628167571-532a6c5f5d16?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8YmVhdXR5JTIwcHJvZHVjdHN8ZW58MHx8MHx8fDA%3D",
                    ""];
    return Scaffold(
      body: categoryAsyncValue.when(
        data: (categories) => GridView.builder(
          physics: const BouncingScrollPhysics(),
          semanticChildCount: categories.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Bounceable(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FutureBuilder<List<Product>>(
                      future: APIService.fetchProductsByCategory(categories[index]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Failed to load products: ${snapshot.error}'),
                          );
                        } else {
                          List<Product> products = snapshot.data ?? [];
                          return DataPage(products: products);
                        }
                      },
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 2,
                width: MediaQuery.of(context).size.width * 0.4,
                child: Card(
                  shadowColor: Colors.blueGrey[300],
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl[index],
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 6.5,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) {
                          return Stack(
                            children: [
                              Center(
                                child: Lottie.asset('asset/lottie1.json'),
                              ),
                            ],
                          );
                        },
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        categories[index],
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
              ),
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Failed to load categories')),
      ),
    );
  }
}
// class Categories {
//   final String title;
//   final String imageUrl;

//   Categories({
//     required this.title,
//     required this.imageUrl, required BoxFit fit,
//   });
// }


// final List<Categories> categories = [
//   Categories(
//     title: 'SmartPhones',
//     imageUrl:
//         'https://images.unsplash.com/photo-1592890288564-76628a30a657?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: 'Laptops',
//     imageUrl:
//         'https://images.unsplash.com/photo-1618410320928-25228d811631?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDEzfHx8ZW58MHx8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Mens-Shirts",
//     imageUrl:
//         'https://images.unsplash.com/photo-1508243529287-e21914733111?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Mens-Shoes",
//     imageUrl:
//         'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=2012&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Mens-Watches",
//     imageUrl:
//         'https://images.unsplash.com/photo-1575125069494-6a0c5819d340?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Sunglasses",
//     imageUrl:
//         'https://images.pexels.com/photos/343720/pexels-photo-343720.jpeg?auto=compress&cs=tinysrgb&w=600',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Womens-Dresses",
//     imageUrl:
//         'https://plus.unsplash.com/premium_photo-1664910175563-a1ecea779c85?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Womens-Shoes",
//     imageUrl:
//         'https://images.unsplash.com/photo-1620683834571-fe8bdb306daf?q=80&w=1931&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Womens-Watches",
//     imageUrl:
//         'https://images.unsplash.com/photo-1490915785914-0af2806c22b6?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Womens-Bags",
//     imageUrl:
//         'https://images.unsplash.com/photo-1524498250077-390f9e378fc0?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Tops",
//     imageUrl:
//         'https://images.unsplash.com/photo-1620799139652-715e4d5b232d?q=80&w=1972&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "jewellery",
//     imageUrl:
//                       'https://images.unsplash.com/photo-1511253819057-5408d4d70465?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',   fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Skincare",
//     imageUrl:
//         'https://images.unsplash.com/photo-1586220742613-b731f66f7743?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Fragrances",
//     imageUrl:
//         'https://images.unsplash.com/photo-1544468266-6a8948003cd7?q=80&w=2074&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Groceries",
//     imageUrl:
//         'https://images.unsplash.com/photo-1542990253-a781e04c0082?q=80&w=1994&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "AutoMotive",
//     imageUrl:
//         'https://plus.unsplash.com/premium_photo-1661589670435-65cfb3224205?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Home-Decoration",
//     imageUrl:
//         'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?q=80&w=2000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Lighting",
//     imageUrl:
//         'https://images.unsplash.com/photo-1611453466149-491a07b6312a?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "Furniture",
//     imageUrl:
//         'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
//   Categories(
//     title: "MotorCycle",
//     imageUrl:
//         'https://images.unsplash.com/photo-1664710713335-755afb757503?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//     fit: BoxFit.fill,
//   ),
// ];
