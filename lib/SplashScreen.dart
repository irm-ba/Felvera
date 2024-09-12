import 'package:flutter/material.dart';
import 'dart:async';
import 'package:felvera/authWarapper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3), // 3 saniye sonra hedef sayfaya geçiş yapar
          () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthWrapper()), // `AuthWrapper` widget'ını yönlendirin
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFC688D3), // İlk renk
              Color(0xFF933A8E), // İkinci renk
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE4C9E5), // Yuvarlağın rengi
                ),
                padding: EdgeInsets.all(60),
                child: Image.asset('assets/images/logo_felveraa.png', width: 120),
              ),
              SizedBox(height: 20),
              Text(
                'FELVERA',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE4C9E5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
