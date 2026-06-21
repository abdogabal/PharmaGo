import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'Providers/DetailsProvider.dart';
import 'Providers/MapPickerProvider.dart';
import 'Providers/MapsProvider.dart';
import 'Providers/ThemeProvider.dart';
import 'Providers/UserProvider.dart';
import 'Providers/CartProvider.dart';
import 'UI/ForgetPassword/Screens/Forget_Password.dart';
import 'UI/Home/Screens/Home_Screen.dart';
import 'UI/Home/Tabs/Calendar/CalendarTab.dart';
import 'Providers/ReminderProvider.dart';
import 'UI/Home/Tabs/Pharma_Home/widgets/Add_Screen.dart';
import 'UI/Home/Tabs/Pharma_Home/widgets/Edit_Screen.dart';
import 'UI/Home/Tabs/Profile/widgets/User_Orders.dart';
import 'UI/Login/Screens/Login_Screen.dart';
import 'UI/Onboarding/Screens/Onboarding_Screen.dart';
import 'UI/PharmacyScreen/Screens/Pharmacy_Screen.dart';
import 'UI/Signup/screens/SignUp_Screen.dart';
import 'UI/Home/Tabs/Calendar/remainder_Screen.dart';
import 'UI/splash/screens/splash_screen.dart';
import 'UI/Cart/CartScreen.dart';
import 'UI/Checkout/PaymentScreen.dart';
import 'UI/Home/Tabs/Home/ScanPrescriptionScreen.dart';
import 'core/PrefsManager.dart';
import 'core/Reusable_component/notification_handler.dart';
import 'core/resources/AppStyle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await PrefsManager.init();
  await Supabase.initialize(
    url: 'https://owwwnnrphgiiyhitdwxe.supabase.co',
    anonKey: 'sb_publishable_AOGuivMoHC9bFX84Ka6u-A_Wvt36L3s',
  );
  await NotificationHandler.init();
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
          ChangeNotifierProvider(create: (context) => MapsProvider()),
          ChangeNotifierProvider(create: (context) => MapPickerProvider()),
          ChangeNotifierProvider(create: (context) => DetailsProvider()),
          ChangeNotifierProvider(create: (context) => CartProvider()),
          ChangeNotifierProvider(create: (context) => ReminderProvider()),
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
    ThemeProviders  provider = Provider.of<ThemeProviders>(context);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_ , child) {
        return MaterialApp(
          theme: AppStyle.lightTheme,
          themeMode: provider.themeMode,
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
            PharmacyScreen.routeName: (_)=>PharmacyScreen(),
            UserOrders.routeName: (_)=>UserOrders(),
            AddScreen.routeName: (_)=>AddScreen(),
            EditScreen.routeName: (_)=>EditScreen(),
            ScheduledPage.routeName: (_)=>ScheduledPage(),
            MedicationListScreen.routeName: (_)=>MedicationListScreen(),
            CartScreen.routeName: (_)=>CartScreen(),
            PaymentScreen.routeName: (_)=>PaymentScreen(),
            ScanPrescriptionScreen.routeName: (_)=>ScanPrescriptionScreen(),
          },
          initialRoute: SplashScreen.routeName,
        );
      },
    );
  }
}

