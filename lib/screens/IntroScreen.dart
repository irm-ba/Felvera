import 'package:felvera/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Hides the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 241, 213, 239),
        padding: EdgeInsets.only(top: screenWidth * 0.1),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  buildPage(
                    "Felvera Evcil Hayvan Platformu",
                    "Felvera'ya Hoş Geldiniz! Sevgi dolu dostlarımızı keşfedin ve hayatlarına neşe katın.",
                    "assets/images/birinci.png",
                  ),
                  buildPage(
                    "Felvera Evcil Hayvan Platformu",
                    "Bizim amacımız sevimli dostlarımızın daha güzel bir yaşam sürmesi. Bunu hep birlikte başarabiliriz.",
                    "assets/images/ikinci.png",
                  ),
                  buildPage(
                    "Felvera Evcil Hayvan Platformu",
                    "Sokak hayvanlarına yuva, kayıp dostlara kavuşma, evcil hayvanlara sıcak bir yuva sunmak için hemen başlayın!",
                    "assets/images/resim.png",
                  ),
                ],
              ),
            ),
            buildDotsIndicator(),
            SizedBox(height: 20),
            buildButtons(context),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildPage(String title, String body, String imagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF933A8E),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          body,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        Image.asset(imagePath, height: 400, width: 400),
      ],
    );
  }

  Widget buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3, // Number of pages
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 10,
          width: _currentIndex == index ? 20 : 10,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? const Color(0xFF933A8E)
                : Colors.black26,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          child: const Text(
            "Atla",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF933A8E),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_currentIndex < 2) {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            }
          },
          child: Text(
            _currentIndex == 2 ? "Devam et" : "İleri",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF933A8E),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
