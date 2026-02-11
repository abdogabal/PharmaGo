import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'Providers/ThemeProvider.dart';
import 'Providers/UserProvider.dart';
import 'UI/ForgetPassword/Screens/Forget_Password.dart';
import 'UI/Home/Screens/Home_Screen.dart';
import 'UI/Login/Screens/Login_Screen.dart';
import 'UI/Onboarding/Screens/Onboarding_Screen.dart';
import 'UI/Signup/screens/SignUp_Screen.dart';
import 'UI/splash/screens/splash_screen.dart';
import 'core/PrefsManager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await PrefsManager.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      saveLocale: true,
      startLocale: Locale('en'),
      fallbackLocale: Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => ThemeProviders()..init()),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_ , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routes: {
            SplashScreen.routeName: (_)=>SplashScreen(),
            HomeScreen.routeName: (_)=>HomeScreen(),
            OnboardingScreen.routeName: (_)=>OnboardingScreen(),
            LoginScreen.routeName: (_)=>LoginScreen(),
            SignUpScreen.routeName: (_)=>SignUpScreen(),
            ForgetPassword.routeName: (_)=>ForgetPassword(),
          },
          initialRoute: SplashScreen.routeName,
        );
      },
    );
  }
}

