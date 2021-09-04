import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData lightThemeData(BuildContext context) {
  // Size screenSize = MediaQuery.of(context).size;
  // print(screenSize);
  return ThemeData.light().copyWith(
    appBarTheme: AppBarTheme(
      backwardsCompatibility: false,
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarColor: Colors.transparent,),
      backgroundColor: Colors.white,
      elevation: 0.0,
      // textTheme: 5
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          primary: Colors.green.shade600,
          elevation: 8,
          shadowColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.normal,
            letterSpacing: 1,
          )),
    ),
    textTheme: ThemeData.light().textTheme.copyWith(
          headline3: TextStyle(
              fontFamily: 'Inter',
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.green[500]),
          headline4: TextStyle(
              fontFamily: 'Inter',
              fontSize: 21,
              fontWeight: FontWeight.w300,
              color: Colors.black.withOpacity(0.6)),
          headline5: TextStyle(
              fontFamily: 'Inter',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          headline6: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.normal),
          bodyText1: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700),
          bodyText2: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: Colors.white60,
              fontWeight: FontWeight.w400),
        ),
  );
}
