import 'package:felvera/constants.dart';
import 'package:felvera/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase/auth.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart'; // FirebaseOptions dosyasını ekleyin

void main() async {
  // Ensure Flutter is properly initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with options for web platform
    print("Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions
          .currentPlatform, // Platforma özel FirebaseOptions ekleyin
    );
    print("Firebase initialized successfully");

    // Hide the system overlays (e.g., status bar, navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // Start the app
    runApp(MyApp());
  } catch (e) {
    // Print any errors that occur during initialization
    print("Error initializing Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      title: 'Felvera', // Title of the app
      theme: ThemeData(
        // Set the background color of the scaffold (whole app)
        scaffoldBackgroundColor: kBackgroundColor,

        // AppBar theme with custom colors
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
        useMaterial3: true, // Enable Material 3 for modern design features
      ),

      // Set the LoginPage as the initial screen of the app
      home: LoginPage(),
    );
  }
}
