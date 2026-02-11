import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharmago/core/Reusable_component/CustomTextField.dart';
import 'package:pharmago/core/resources/AssetsManger.dart';

import '../../../core/DialogUtils.dart';
import '../../../core/Reusable_component/CustomButton.dart';
import '../../../core/resources/StringsManger.dart';
import '../../../core/resources/constans.dart';

class ForgetPassword extends StatefulWidget {
  static const String routeName = 'forgetPass';

  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  late TextEditingController emailController;
  late TextEditingController passController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          StringsManger.forgetPass.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  CustomTextField(
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return StringsManger.wrong.tr();
                      } else if (!RegExp(emailRegex).hasMatch(value)) {
                        return 'Email not valid';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    prefixIcon: AssetsManger.email,
                    hint: StringsManger.enterEmail.tr(),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    child: CustomButton(
                      title: StringsManger.resetPass.tr(),
                      onClick: () {
                        if (formKey.currentState?.validate() ?? false) {
                          resetPass();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  resetPass() async {
    try {
      DialogUtils.showLoading(context);
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );
      Navigator.pop(context);
      DialogUtils.showSnackBar( StringsManger.resetLinkSent.tr());
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == "user-not-found") {
        DialogUtils.showMassageDialog(
          context: context,
          massage: StringsManger.noUserAcc.tr(),
          posTitle: StringsManger.ok.tr(),
          posClick: () {
            Navigator.pop(context);
          },
        );
      } else {
        DialogUtils.showMassageDialog(
          context: context,
          massage: e.code,
          posTitle: StringsManger.ok.tr(),
          posClick: () {
            Navigator.pop(context);
          },
        );
      }
    }
  }
}
