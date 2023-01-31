import 'package:flutter/material.dart';

class ColorPalette {
  static Color splashScreenDarkColor = Color(0xFF1A120B);
  static Color splashScreenLightColor = Color(0xFFFFFFFF);
  static Color primaryColor = Color(0xFF4DCCC6);
  static Color secondColor = Color(0xFF9EABE4);
  static Color textColor = Color(0xFF1A120B);
  static Color appbarTextColor = Color(0xFFFFFFFF);
  static Color backgroundScaffoldColor = Color(0xFFFFFFFF);
  static Color shadowColor = Color(0xFF567189);
  static List<Color> buttonColor = [
    ColorPalette.secondColor,
    ColorPalette.primaryColor
  ];
  static Color textButtonColor = Color(0xFFFFFFFF);
  static Color cancelColor = Color(0xFFFF6464);
  static Color borderColor = Color(0xFFFFFFFF);
  static Color grammarColor = Color(0xFFC62828);
  static Color typoColor = Color(0xFFEF6C00);
  static Color spellColor = Color(0xFF1565C0);
  static Color puncColor = Color(0xFFFB8C00);
  static Color grammarBackgroundColor = Color(0xFFEF9A9A);
  static Color typoBackgroundColor = Color(0xFFFFCC80);
  static Color spellBackgroundColor = Color(0xFF90CAF9);
  static Color puncBackgroundColor = Color(0xFFFFE0B2);
  static Color toggleOffColor = Color(0xFF1A120B);
  static Color toggleActiveColor = Color(0xFFFB8C00);
  static Color toggleActiveTrackColor = Color(0xFFFFE0B2);

  static void changeTheme(bool isDarkTheme) {
    if (isDarkTheme) {
      backgroundScaffoldColor = Color(0xFF000000);
      textColor = Color(0xFFFFFFFF);
      shadowColor = Color(0xFFFFFFFF);
      borderColor = Color(0xFF3F0071);
    } else {
      backgroundScaffoldColor = Color(0xFFFFFFFF);
      textColor = Color(0xFF1A120B);
      shadowColor = Color(0xFF567189);
      borderColor = Color(0xFFFFFFFF);
    }
  }
}

class Gradients {
  static const Gradient defaultGradientBackground = LinearGradient(
      begin: Alignment.centerRight, end: Alignment.centerLeft, colors: []);
}
