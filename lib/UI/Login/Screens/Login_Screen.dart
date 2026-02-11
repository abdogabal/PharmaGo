import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharmago/core/Reusable_component/CustomTextField.dart';
import 'package:pharmago/core/resources/AssetsManger.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:pharmago/core/resources/StringsManger.dart';
import 'package:provider/provider.dart';

import '../../../Models/User.dart' as MyUser;
import '../../../Providers/UserProvider.dart';
import '../../../core/DialogUtils.dart';
import '../../../core/FirestoreHandler.dart';
import '../../../core/Reusable_component/CustomButton.dart';
import '../../../core/resources/constans.dart';
import '../../ForgetPassword/Screens/Forget_Password.dart';
import '../../Home/Screens/Home_Screen.dart';
import '../../Signup/screens/SignUp_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          StringsManger.login.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                    controller: emailController,
                    hint: StringsManger.enterEmail.tr(),
                    prefixIcon: AssetsManger.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return StringsManger.passWrong.tr();
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 character';
                      }
                      return null;
                    },
                    controller: passController,
                    hint: StringsManger.enterPass.tr(),
                    prefixIcon: AssetsManger.lock,
                    keyboardType: TextInputType.visiblePassword,
                    obscure: true,
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, ForgetPassword.routeName);
                      },
                      child: Text(
                        StringsManger.forgetPass.tr(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    child: CustomButton(
                      title: StringsManger.login.tr(),
                      onClick: () {
                        if (formKey.currentState?.validate() ?? false) {
                          login();
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        StringsManger.haveAcc.tr(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, SignUpScreen.routeName);
                        },
                        child: Text(
                          StringsManger.signup.tr(),
                          style: Theme.of(context).textTheme.labelSmall!
                              .copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16),
                      Expanded(
                        child: Divider(height: 20.h, color: ColorManger.green),
                      ),
                      SizedBox(width: 16.w),

                      Text(
                        StringsManger.or.tr(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      SizedBox(width: 16.w),

                      Expanded(
                        child: Divider(height: 1.h, color: ColorManger.green),
                      ),

                      SizedBox(width: 16.w),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        loginWithGoogle();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Image.asset(
                                AssetsManger.google,
                                height: 24,
                              ),
                            ),
                          ),
                          Text(
                            StringsManger.withGoogle.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
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

  Future<void> loginWithGoogle() async {
    final UserProvider provider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    DialogUtils.showLoading(context);

    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Sign in with Firebase
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      await FirestoreHandler.addUser(
        MyUser.User(
          id: userCredential.user?.uid ?? '',
          // Use Firebase UID instead of providerId
          name: googleUser.displayName ?? '',
          email: googleUser.email ?? '',
        ),
      );

      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (routeName) => false,
      );
    } catch (e) {
      Navigator.pop(context);
      DialogUtils.showMassageDialog(
        context: context,
        massage: e.toString(),
        posTitle: StringsManger.ok.tr(),
        posClick: () {
          Navigator.pop(context);
        },
      );
    }
  }

  login() async {
    UserProvider provider = Provider.of<UserProvider>(context, listen: false);
    try {
      DialogUtils.showLoading(context);
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text,
            password: passController.text,
          );
      MyUser.User? myUser = await FirestoreHandler.getUser(
        credential.user?.uid ?? "",
      );
      provider.saveUser(myUser);
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (routeName) => false,
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        DialogUtils.showMassageDialog(
          context: context,
          massage: StringsManger.wrong.tr(),
          posTitle: StringsManger.ok.tr(),
          posClick: () {
            Navigator.pop(context);
          },
        );
      } else if (e.code == 'wrong-password') {
        DialogUtils.showMassageDialog(
          context: context,
          massage: StringsManger.passWrong.tr(),
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
