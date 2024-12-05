import 'package:felvera/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hides the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 241, 213, 239),
        padding: EdgeInsets.only(top: screenWidth * 0.1),
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "Felvera Evcil Hayvan Platformu",
              body:
                  "Felvera'ya Hoş Geldiniz! Sevgi dolu dostlarımızı keşfedin ve hayatlarına neşe katın.",
              image: Image.asset("assets/images/birinci.png",
                  height: 400, width: 400),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: "Felvera Evcil Hayvan Platformu",
              body:
                  "Bizim amacımız sevimli dostlarımızın daha güzel bir yaşam sürmesi. Bunu hep birlikte başarabiliriz.",
              image: Image.asset("assets/images/ikinci.png",
                  height: 400, width: 400),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: "Felvera Evcil Hayvan Platformu",
              body:
                  "Sokak hayvanlarına yuva, kayıp dostlara kavuşma, evcil hayvanlara sıcak bir yuva sunmak için hemen başlayın!",
              image: Image.asset("assets/images/resim.png",
                  height: 400, width: 400),
              decoration: getPageDecoration(),
            ),
          ],
          onDone: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          onSkip: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          showSkipButton: true,
          skip: const Text(
            "Atla",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF933A8E),
            ),
          ),
          next: const Icon(Icons.arrow_forward, color: Color(0xFF933A8E)),
          done: const Text(
            "Devam et",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF933A8E),
            ),
          ),
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            color: Colors.black26,
            activeColor: const Color(0xFF933A8E),
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
          // Setting the background color for the bottom bar
          globalBackgroundColor: const Color.fromARGB(255, 240, 222, 238),
        ),
      ),
    );
  }

  // Helper method for styling each page
  PageDecoration getPageDecoration() => const PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF933A8E),
        ),
        bodyTextStyle: TextStyle(fontSize: 16),
        pageColor: Color.fromARGB(255, 241, 213, 239),
      );
}
