import 'package:flutter/material.dart';
import 'dart:async';
import 'package:felvera/authWarapper.dart';
import 'package:felvera/main.dart'; // RouteObserver'ın olduğu yeri import etmeliyiz

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with RouteAware {
  Timer? _timer; // Zamanlayıcı referansı
  bool _isNavigated = false; // Navigasyon yapılıp yapılmadığını kontrol eden bayrak

  @override
  void initState() {
    super.initState();
    // Zamanlayıcıyı başlatıyoruz
    _timer = Timer(
      Duration(seconds: 2), // 10 saniye sonra hedef sayfaya geçiş yapar
          () {
        if (!_isNavigated) {
          _isNavigated = true;  // Navigasyon yapılmış olarak işaretle
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AuthWrapper()), // `AuthWrapper` widget'ına yönlendirin
          );
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ModalRoute'un bir PageRoute olup olmadığını kontrol ediyoruz
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute); // RouteObserver'a abone ol
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // RouteObserver'dan çık
    _timer?.cancel(); // Zamanlayıcıyı iptal et
    super.dispose();
  }

  // Sayfa değişikliği olduğunda (örn. /support'a geçildiğinde)
  @override
  void didPushNext() {
    _timer?.cancel(); // Yeni bir sayfaya geçildiğinde zamanlayıcıyı iptal et
    print("Zamanlayıcı iptal edildi çünkü başka bir sayfaya geçildi.");
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
