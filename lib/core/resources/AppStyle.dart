import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharmago/core/resources/ColorManger.dart';

class AppStyle {
  static ThemeMode themeMode = ThemeMode.light;
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorManger.white,
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 22.sp,
        color: ColorManger.black,
        fontWeight: FontWeight.bold,
      ),
      labelSmall: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: ColorManger.green,
      ),
      labelMedium: TextStyle(
        fontSize: 16.sp,
        color:ColorManger.green,
        fontWeight: FontWeight.w600
      ),

        titleMedium: TextStyle(
        fontSize: 16.sp,
        color:ColorManger.black,
        fontWeight: FontWeight.w700
      )
    ),
  );
}
