import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_loader/easy_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:go_shop/E-Shop/Api/api.dart';
import 'package:go_shop/E-Shop/Api/apimodel.dart';
import 'package:go_shop/E-Shop/Pages/product_page/product_section.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryHome extends ConsumerWidget {
 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsyncValue = ref.watch(APIService.categoryProvider);
   List imageUrl =["https://plus.unsplash.com/premium_photo-1673628167571-532a6c5f5d16?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8YmVhdXR5JTIwcHJvZHVjdHN8ZW58MHx8MHx8fDA%3D",
                    "https://plus.unsplash.com/premium_photo-1679106770086-f4355693be1b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8cGVyZnVtZSUyMHNwcmF5fGVufDB8fDB8fHww",
                    "https://plus.unsplash.com/premium_photo-1673548917423-073963e7afc9?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8ZnVybml0dXJlfGVufDB8fDB8fHww",
                    "https://images.unsplash.com/photo-1579113800032-c38bd7635818?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fGdyb2Nlcnl8ZW58MHx8MHx8fDA%3D",
                    "https://images.unsplash.com/photo-1582131503261-fca1d1c0589f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGhvbWUlMjBkZWNvcnxlbnwwfHwwfHx8MA%3D%3D",
                    "https://images.unsplash.com/photo-1556185781-a47769abb7ee?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8a2l0Y2hlbiUyMGFjY2Vzc29yaWVzfGVufDB8fDB8fHww",
                    "https://images.unsplash.com/photo-1526657782461-9fe13402a841?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhcHRvcHxlbnwwfHwwfHx8MA%3D%3D",
                    "https://images.unsplash.com/photo-1603252109303-2751441dd157?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHNoaXJ0fGVufDB8fDB8fHww",
                    "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8c2hvZXN8ZW58MHx8MHx8fDA%3D",
                    "https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHdhdGNofGVufDB8fDB8fHww",
                    "https://images.unsplash.com/photo-1596207498818-edb80522f50b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8Z2FkZ2V0fGVufDB8fDB8fHww",
                    "https://images.unsplash.com/photo-1614152412509-7a5afc18c75b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fG1vdG9yJTIwYmlrZXxlbnwwfHwwfHx8MA%3D%3D",
                    "https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fHNraW5jYXJlfGVufDB8fDB8fHww",
                    "https://images.unsplash.com/photo-1592890288564-76628a30a657?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fHBob25lfGVufDB8fDB8fHww",
                    "https://images.unsplash.com/photo-1589487391730-58f20eb2c308?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8Zm9vdGJhbGx8ZW58MHx8MHx8fDA%3D",
                    "https://images.unsplash.com/photo-1515613813261-5cd015bcd184?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8c3VuJTIwZ2xhc3N8ZW58MHx8MHx8fDA%3D",
                    "https://images.unsplash.com/photo-1542751110-97427bbecf20?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8dGFibGV0fGVufDB8fDB8fHww",
                    "https://images.unsplash.com/photo-1533736970669-7edc3f971be1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDB8fHdvbWVuJTIwZHJlc3Nlc3xlbnwwfHwwfHx8MA%3D%3D",
                    "https://images.unsplash.com/photo-1493238792000-8113da705763?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fGNhcnN8ZW58MHx8MHx8fDA%3D",
                    "https://images.unsplash.com/photo-1589731119540-c4586781dae1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjh8fGxhZGllcyUyMGhhbmRiYWd8ZW58MHx8MHx8fDA%3D",
                    "https://plus.unsplash.com/premium_photo-1661661855747-29818fbf6e9b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjkzfHx3b21lbiUyMGRyZXNzZXN8ZW58MHx8MHx8fDA%3D",
                    "https://images.unsplash.com/photo-1617074172287-f364b77c1e77?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZWFycmluZ3N8ZW58MHx8MHx8fDA%3D",
                    "https://images.unsplash.com/photo-1515347619252-60a4bf4fff4f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhZGllcyUyMHNob2VzfGVufDB8fDB8fHww",
                    "https://images.unsplash.com/photo-1653651460792-34c383a224fb?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bGFkaWVzJTIwd2F0Y2hlc3xlbnwwfHwwfHx8MA%3D%3D",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    ];
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
        loading: () =>  Center(
                                child: EasyLoader(image: AssetImage("asset/logo.png"),),
                              ),
        error: (error, stackTrace) => Center(child: Text('Failed to load categories')),
      ),
    );
  }
}