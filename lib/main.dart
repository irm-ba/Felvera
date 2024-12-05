import 'package:felvera/AuthWarapper.dart';
import 'package:felvera/Contact.dart';
import 'package:felvera/screens/IntroScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:felvera/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'splashscreen.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy(); // Temiz URL stratejisini kullan

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    runApp(const MyApp());
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Felvera',
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundColor,
          iconTheme: IconThemeData(color: kBrownColor),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: kBrownColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver], // RouteObserver burada ekleniyor
      initialRoute: '/', // Başlangıç rotasını ana sayfa yapın
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/support':
            return MaterialPageRoute(
                builder: (context) => ContactPage(), settings: settings);
          default:
            return MaterialPageRoute(
                builder: (context) => AuthWrapper(), settings: settings);
        }
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''), // Türkçe
        Locale('en', ''), // İngilizce
      ],
    );
  }
}
