import 'package:flutter/material.dart';

class AppTheme {
  // 🔹 Couleurs principales
  static const Color mainColor = Color(0xFF629EB9);
  static const Color blancColor = Color(0xFFFFFFFF);
  static const Color backgroundColor1 = Color(0xFFA6C0D6);
  static const Color backgroundColor2 = Color(0xFFF8FAFC);

  // 🔹 Police
  static const String fontFamily = "Open Sans";

  // 🔹 Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: mainColor,
    scaffoldBackgroundColor: backgroundColor2,
    fontFamily: fontFamily,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.normal),
      displayLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.normal),
      titleMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.normal),
      titleSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: mainColor,
      foregroundColor: blancColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: blancColor,
      ),
      iconTheme: IconThemeData(color: blancColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mainColor,
        foregroundColor: blancColor,
        textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
