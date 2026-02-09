import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharmago/UI/Onboarding/widgets/PageViewOnboarding.dart';
import 'package:pharmago/core/resources/AssetsManger.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:pharmago/core/resources/StringsManger.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../Models/OnboardingModal.dart';
import '../../../core/PrefsManager.dart';
import '../../Login/Screens/Login_Screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = 'onboard';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int pos = 0;
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    List<OnboardingModel> onboardingModel = [
      OnboardingModel(
        image: AssetsManger.onboarding1,
        text: StringsManger.onboarding1.tr(),
      ),
      OnboardingModel(
        image: AssetsManger.onboarding2,
        text: StringsManger.onboarding2.tr(),
      ),
      OnboardingModel(
        image: AssetsManger.onboarding3,
        text: StringsManger.onboarding3.tr(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 27),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                onPageChanged: (index) {
                  pos = index;
                  setState(() {});
                },
                controller: pageController,
                itemBuilder:
                    (context, index) =>
                        PageViewOnboarding(model: onboardingModel[index]),
                itemCount: onboardingModel.length,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManger.green,
                    shape: CircleBorder(
                      side: BorderSide(width: 45.h, color: ColorManger.green),
                    ),
                  ),
                  onPressed: () {
                    PrefsManager.onboardingFirstTime();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginScreen.routeName,
                      (route) => false,
                    );
                  },
                  child: Text(
                    StringsManger.skip.tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: ColorManger.white),
                  ),
                ),

                SmoothPageIndicator(
                  controller: pageController,
                  count: onboardingModel.length,

                  effect: ScaleEffect(
                    scale: 1.4,
                    dotHeight: 8.h,
                    dotWidth: 8.w,
                  ),
                ),
                Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: ColorManger.green,
                      shape: CircleBorder(
                        side: BorderSide(width: 45.h, color: ColorManger.green),
                      ),
                    ),
                    onPressed: () {
                      if (pos < (onboardingModel.length - 1)) {
                        pageController.nextPage(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.linear,
                        );
                      } else {
                        PrefsManager.onboardingFirstTime();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          LoginScreen.routeName,
                          (route) => false,
                        );
                      }
                    },
                    icon: Icon(Icons.arrow_forward, color: ColorManger.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 38.h),
          ],
        ),
      ),
    );
  }
}
