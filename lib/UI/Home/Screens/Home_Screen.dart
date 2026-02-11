import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharmago/UI/Home/Tabs/Calendar/CalendarTab.dart';
import 'package:pharmago/UI/Home/Tabs/Home/HomeTab.dart';
import 'package:pharmago/UI/splash/screens/splash_screen.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:provider/provider.dart';

import '../../../Models/User.dart' as MyUser;
import '../../../Providers/MapsProvider.dart';
import '../../../Providers/UserProvider.dart';
import '../../../core/FirestoreHandler.dart';
import '../../../core/resources/AssetsManger.dart';
import '../../../core/resources/StringsManger.dart';
import '../Tabs/Map/MapTab.dart';
import '../Tabs/Profile/ProfileTab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTap = 0;
  List<Widget> tabs = [HomeTab(), MapTab(), CalendarTab(), ProfileTab()];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFirestoreUser();
  }

  getFirestoreUser() async {
    UserProvider provider = Provider.of<UserProvider>(context, listen: false);
     MapsProvider mapsProvider = Provider.of<MapsProvider>(
        context,
        listen: false,
      );
    if (provider.myUser == null) {
      MyUser.User? user = await FirestoreHandler.getUser(
        FirebaseAuth.instance.currentUser?.uid ?? "",
      );
      provider.saveUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    MapsProvider mapsProvider = Provider.of<MapsProvider>(context);
    UserProvider provider = Provider.of<UserProvider>(context);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            selectedTap = value;
          });
        },
        currentIndex: selectedTap,
        items: [
          BottomNavigationBarItem(
            label: StringsManger.home.tr(),

            icon: SvgPicture.asset(
              AssetsManger.home,
              width: 24.w,
              height: 24.h,
            ),
            activeIcon: SvgPicture.asset(
              AssetsManger.homeSelected,
              width: 24.w,
              height: 24.h,
            ),
          ),
          BottomNavigationBarItem(
          label: StringsManger.map.tr(),
            icon: SvgPicture.asset(
              AssetsManger.map,
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(ColorManger.green, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              AssetsManger.mapSelected,
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(ColorManger.green, BlendMode.srcIn),
            ),
          ),
          BottomNavigationBarItem(
          label: StringsManger.calendar.tr(),
            icon: SvgPicture.asset(
              AssetsManger.calendar,
              width: 24.w,
              height: 24.h,
            ),
            activeIcon: SvgPicture.asset(
              AssetsManger.calendarSelected,
              width: 24.w,
              height: 24.h,
            ),
          ),
          BottomNavigationBarItem(
            label: StringsManger.profile.tr(),
            icon: SvgPicture.asset(
              AssetsManger.profile,
              width: 24.w,
              height: 24.h,
            ),
            activeIcon: SvgPicture.asset(
              AssetsManger.profileSelected,
              width: 24.w,
              height: 24.h,
            ),
          ),
        ],
      ),
      body: tabs[selectedTap],
    );
  }
}
