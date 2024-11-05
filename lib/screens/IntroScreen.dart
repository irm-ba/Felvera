import 'package:felvera/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hides the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      body: PageView(
        physics: BouncingScrollPhysics(),
        children: [
          buildPage(
            title: "Felvera Evcil Hayvan Platformu",
            body:
                "Felvera'ya Hoş Geldiniz! Sevgi dolu dostlarımızı keşfedin ve hayatlarına neşe katın.",
            imagePath: "assets/images/birinci.png",
          ),
          buildPage(
            title: "Felvera Evcil Hayvan Platformu",
            body:
                "Bizim amacımız sevimli dostlarımızın daha güzel bir yaşam sürmesi. Bunu hep birlikte başarabiliriz.",
            imagePath: "assets/images/ikinci.png",
          ),
          buildPage(
            title: "Felvera Evcil Hayvan Platformu",
            body:
                "Sokak hayvanlarına yuva, kayıp dostlara kavuşma, evcil hayvanlara sıcak bir yuva sunmak için hemen başlayın!",
            imagePath: "assets/images/resim.png",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignupPage()),
          );
        },
        child: Icon(Icons.arrow_forward),
        backgroundColor: Color(0xFF6C63FF),
      ),
    );
  }

  Widget buildPage(
      {required String title,
      required String body,
      required String imagePath}) {
    return Container(
      color: Color.fromARGB(255, 241, 213, 239),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 147, 58, 142), // Purple color
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Image.asset(
            imagePath,
            height: 400,
            width: 400,
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
