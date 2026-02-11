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
        color: ColorManger.green,
        fontWeight: FontWeight.w600,
      ),

      titleMedium: TextStyle(
        fontSize: 16.sp,
        color: ColorManger.black,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        fontSize: 35.sp,
        color: ColorManger.white,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ColorManger.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: ColorManger.green,
      unselectedItemColor: ColorManger.white,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: ColorManger.green,
        fontSize: 12.sp,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: ColorManger.white,
        fontSize: 12.sp,
      ),
    ),
  );
}
