import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Models/OnboardingModal.dart';

class PageViewOnboarding extends StatelessWidget {
  OnboardingModel model;

  PageViewOnboarding({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [Image.asset(model.image, fit: BoxFit.contain),
        SizedBox(height: 10.h,),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              softWrap: true,
              model.text.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.start,
            ),
          ),

        ],
      ),
    );
  }
}
