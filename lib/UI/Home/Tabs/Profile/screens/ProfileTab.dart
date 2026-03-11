import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharmago/Core/resources/StringsManger.dart';
import 'package:pharmago/UI/Login/Screens/Login_Screen.dart';
import 'package:pharmago/core/resources/AssetsManger.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:provider/provider.dart';

import '../../../../../Providers/UserProvider.dart';
import '../widgets/User_Orders.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: ColorManger.green,
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Center(
                child:
                    userProvider.myUser == null
                        ? CircularProgressIndicator()
                        : Text(
                          userProvider.myUser?.name ?? '',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorManger.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(AssetsManger.profile),
                        SizedBox(width: 8.w),
                        Text(
                          userProvider.myUser?.name ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Divider(height: 20.h, color: ColorManger.black),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(AssetsManger.email),
                        SizedBox(width: 8.w),
                        Text(
                          userProvider.myUser?.email ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Divider(height: 20.h, color: ColorManger.black),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AssetsManger.number,
                          colorFilter: ColorFilter.mode(
                            ColorManger.green,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          userProvider.myUser?.number ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Visibility(
                      visible:  userProvider.myUser?.pharmacy==false,
                      child: Expanded(
                        child: Divider(height: 20.h, color: ColorManger.black),
                      ),
                    ),
                    Visibility(
                      visible:  userProvider.myUser?.pharmacy==false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.history, color: ColorManger.green),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  UserOrders.routeName,
                                );
                              },
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  StringsManger.orders.tr(),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Divider(height: 20.h, color: ColorManger.black),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.logout, color: ColorManger.green),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Supabase.instance.client.auth.signOut();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                LoginScreen.routeName,
                                (route) => false,
                              );
                            },
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                StringsManger.logout,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
