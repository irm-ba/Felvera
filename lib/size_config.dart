import 'package:flutter/widgets.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double textMultiplier;

  // Bu değerler referans ekran boyutlarıdır
  static double baseWidth = 375.0;  // Genişlik referansı (örneğin iPhone 11 genişliği)
  static double baseHeight = 812.0; // Yükseklik referansı (örneğin iPhone 11 yüksekliği)

  void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    // Genişlik ve yüksekliğe göre orantılı bir metin ölçeklendirme değeri
    textMultiplier = (screenWidth / baseWidth + screenHeight / baseHeight) / 2;
  }

  static double scaledFontSize(double fontSize) {
    return fontSize * textMultiplier;
  }
}
