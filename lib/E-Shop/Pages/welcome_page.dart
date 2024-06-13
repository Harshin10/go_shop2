import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_shop/E-Shop/Pages/login_page.dart';

// Main Application

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Future<bool> _checkIfIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('intro_seen') ?? false;
  }

  void _setIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_seen', true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfIntroSeen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while checking
        } else {
          final introSeen = snapshot.data ?? false;
          if (!introSeen) {
            _setIntroSeen();
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: introSeen ? LoginPage() : IntroPage(),
          );
        }
      },
    );
  }
}

// Introduction Page

class IntroPage extends StatelessWidget {
  static const routeName = '/intro';

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    final pageIndex = ValueNotifier<int>(0);

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Image.asset("asset/background.png"),
          ),
          PageView(
            controller: controller,
            onPageChanged: (index) {
              pageIndex.value = index;
            },
            children: [
              buildPage(
                context,
                'asset/firstScreen.png',
                'Search Product',
                'Easily find products within the Go Shop app by entering keywords or phrases into the search bar.',
              ),
              buildPage(
                context,
                'asset/secondScreen.png',
                'Order Protection',
                'Go Shop ensures secure transactions, prioritizing the safety of users with every purchase.',
              ),
              buildPage(
                context,
                'asset/thirdScreen.png',
                'Product Quality',
                'Go Shop ensures the security of every product, prioritizing quality and authenticity for its users.',
              ),
            ],
          ),
          buildPageIndicator(pageIndex),
          buildNavigationButtons(context, controller, pageIndex),
        ],
      ),
    );
  }

  Widget buildPage(BuildContext context, String image, String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Center(
          child: Image.asset(
            image,
            height: 200,
            width: 200,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16.0),
          child: Text(
            description,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
        ),
      ],
    );
  }

  Positioned buildPageIndicator(ValueNotifier<int> pageIndex) {
    return Positioned(
      bottom: 56.0, // Adjusted to avoid overlap with navigation buttons
      left: 0,
      right: 0,
      child: ValueListenableBuilder<int>(
        valueListenable: pageIndex,
        builder: (context, value, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildIndicatorDot(value == 0),
              buildIndicatorDot(value == 1),
              buildIndicatorDot(value == 2),
            ],
          );
        },
      ),
    );
  }

  Container buildIndicatorDot(bool isActive) {
    return Container(
      margin: EdgeInsets.all(8.0),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
        color: isActive ? Colors.yellow : Colors.white,
      ),
    );
  }

  Positioned buildNavigationButtons(BuildContext context, PageController controller, ValueNotifier<int> pageIndex) {
    return Positioned(
      bottom: 16.0,
      left: 16.0,
      right: 16.0,
      child: ValueListenableBuilder<int>(
        valueListenable: pageIndex,
        builder: (context, value, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (value != 0)
                TextButton(
                  onPressed: () {
                    controller.previousPage(duration: Duration(milliseconds: 200), curve: Curves.linear);
                  },
                  child: Text('Back'),
                ),
              if (value != 2)
                TextButton(
                  onPressed: () {
                    controller.nextPage(duration: Duration(milliseconds: 200), curve: Curves.linear);
                  },
                  child: Text('Next'),
                ),
              if (value == 2)
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Finish'),
                ),
            ],
          );
        },
      ),
    );
  }
}