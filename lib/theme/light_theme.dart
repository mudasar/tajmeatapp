import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Poppins',
  primaryColor: Color(0xffbf0000),
  brightness: Brightness.light,
  cardColor: Colors.white,
  focusColor: Color(0xFFADC4C8),
  hintColor: Color(0xFF52575C),
  textTheme: TextTheme(headline6: TextStyle(color: Color(0xFFE0E0E0))),
  pageTransitionsTheme: PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);