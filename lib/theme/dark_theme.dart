import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Poppins',
  primaryColor: Color(0xffbf0000).withOpacity(0.6),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF2C2C2C),

  cardColor: Color(0xFF121212),
  hintColor: Color(0xFFE7F6F8),
  focusColor: Color(0xFFADC4C8),
  textTheme: TextTheme(headline6: TextStyle(color: Color(0xFFE0E0E0).withOpacity(0.3))),
  pageTransitionsTheme: PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);
