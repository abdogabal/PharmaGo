import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharmago/UI/Login/Screens/Login_Screen.dart';
import 'package:pharmago/UI/Onboarding/Screens/Onboarding_Screen.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:pharmago/core/resources/StringsManger.dart';

import '../../../core/PrefsManager.dart';
import '../../../core/resources/AssetsManger.dart';
import '../../Home/Screens/Home_Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = 'Splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(
        check()
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManger.green,
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
                  AssetsManger.logo,
                  colorFilter: ColorFilter.mode(
                    ColorManger.white,
                    BlendMode.srcIn,
                  ),
                )
                .animate()
                .slideX(duration: Duration(milliseconds: 800))
                .then()
                .scale(begin: Offset(0.5, 0.5)),
            Text(
              StringsManger.splashTitle.tr(),
              style: TextStyle(
                color: ColorManger.white,
                fontSize: 50.11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String check() {
    if (Supabase.instance.client.auth.currentSession != null) {
      return HomeScreen.routeName;
    } else {
      if (PrefsManager.onboardingActive()) {
        return OnboardingScreen.routeName;
      } else {
        return LoginScreen.routeName;
      }
    }
  }
}
