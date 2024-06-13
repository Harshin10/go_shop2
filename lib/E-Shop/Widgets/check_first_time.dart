import 'package:flutter/material.dart';
import 'package:go_shop/E-Shop/Pages/login_page.dart';

class IntroPage extends StatefulWidget {
  final VoidCallback onFinished;

  IntroPage({required this.onFinished});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  PageController controller = PageController();
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey[100],
            image: DecorationImage(image: AssetImage('asset/background.png'))),
        child: Stack(
          children: <Widget>[
            PageView(
              onPageChanged: (value) {
                setState(() {
                  pageIndex = value;
                });
              },
              controller: controller,
              children: <Widget>[
                buildPage('asset/firstScreen.png', '"Go Shop" Search Product',
                    'Easily find products within the Go Shop app by entering keywords or phrases into the search bar,'),
                buildPage('asset/secondScreen.png', '"Go Shop" Order Protection',
                    '"Go Shop" ensures secure transactions, prioritizing the safety of users with every purchase'),
                buildPage('asset/thirdScreen.png', '"Go Shop" product quality',
                    '"Go Shop" ensures the security of every product, prioritizing quality and authenticity for its users.'),
              ],
            ),
            Positioned(
              bottom: 16.0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.all(8.0),
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                              color: pageIndex == index
                                  ? Colors.yellow
                                  : Colors.white),
                        );
                      }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Opacity(
                          opacity: pageIndex != 2 ? 1.0 : 0.0,
                          child: TextButton(
                            child: Text(
                              'SKIP',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            onPressed: () {
                              widget.onFinished();
 Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );                            },
                          ),
                        ),
                        pageIndex != 2
                            ? TextButton(
                                child: Text(
                                  'NEXT',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                onPressed: () {
                                  controller.nextPage(
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.linear);
                                },
                              )
                            : TextButton(
                                child: Text(
                                  'FINISH',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                onPressed: () {
                                  widget.onFinished();
                                   Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
                                },
                              )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Column buildPage(String imagePath, String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Center(
          child: Image.asset(
            imagePath,
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
}
