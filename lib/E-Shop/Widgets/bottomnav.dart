import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:go_shop/E-Shop/Pages/cart_page.dart';
import 'package:go_shop/E-Shop/Pages/favorite_page.dart';
import 'package:go_shop/E-Shop/Pages/home_page.dart';
import 'package:go_shop/E-Shop/Pages/product_page/category_home_page.dart';
import 'package:go_shop/E-Shop/Pages/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool willLeave = false;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return GiffyDialog.image(
              Image.asset(
                "asset/logo.png",
                height: 200,
                fit: BoxFit.cover,
              ),
              title: Text(
                'Do You Want To Logout!',
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 85, 84, 84),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'CANCEL'),
                  child: const Text(
                    'CANCEL',
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueGrey,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                          SystemNavigator.pop(); 

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error logging out: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red[400],
                  ),
                ),
              ],
            );
          },
        );
        return willLeave;
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            HomePage(),
             CategoryHome(),
            Profile(),
            FavoritesScreen(),
            CartScreen(),
          ],
        ),
        bottomNavigationBar: FlashyTabBar(
          selectedIndex: _selectedIndex,
          showElevation: true,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          items: [
            FlashyTabBarItem(
              icon: const Icon(Icons.home_rounded),
              title: const Text('Home'),
            ),
            FlashyTabBarItem(
              icon: const Icon(Icons.public_rounded),
              title: const Text('Category'),
            ),
            FlashyTabBarItem(
              icon: const Icon(Icons.account_circle_rounded),
              title: const Text('Profile'),
            ),
            FlashyTabBarItem(
              icon: const Icon(Icons.favorite),
              title: const Text('Favorite'),
            ),
            FlashyTabBarItem(
              icon: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
