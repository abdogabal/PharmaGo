import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharmago/core/Reusable_component/CustomTextField.dart';
import 'package:pharmago/core/resources/AssetsManger.dart';
import 'package:provider/provider.dart';
import '../../../Models/User.dart' as MyUser;
import '../../../Providers/UserProvider.dart';
import '../../../core/DialogUtils.dart';
import '../../../core/SupabaseHandler.dart';
import '../../../core/Reusable_component/CustomButton.dart';
import '../../../core/resources/StringsManger.dart';
import '../../../core/resources/constans.dart';
import '../../Home/Screens/Home_Screen.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = 'signup';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passController;
  late TextEditingController numbController;
  late TextEditingController repassController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passController = TextEditingController();
    repassController = TextEditingController();
    numbController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    repassController.dispose();
    numbController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          StringsManger.signup.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Padding(
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
                    }
                    return null;
                  },
                  controller: nameController,
                  hint: StringsManger.enterName.tr(),
                  prefixIcon: AssetsManger.user,
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  validate: (value) {
                    if (value == null || value.isEmpty|| value.length != 11) {
                      return StringsManger.wrong.tr();
                    }
                    return null;
                  },
                  controller: numbController,
                  hint: StringsManger.enterNumber.tr(),
                  prefixIcon: AssetsManger.number,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.h),
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
                SizedBox(height: 16.h,),
                Container(
                  width: double.infinity,
                  child: CustomButton(
                    title: StringsManger.signup.tr(),
                    onClick: () {
                      if (formKey.currentState?.validate() ?? false) {
                        signup();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  signup() async {
    UserProvider provider = Provider.of<UserProvider>(context, listen: false);
    try {
      DialogUtils.showLoading(context);
      AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passController.text,
      );
      await SupabaseHandler.addUser(
        MyUser.User(
          id: response.user?.id,
          name: nameController.text,
          email: emailController.text,
          number: numbController.text
        ),
      );
      MyUser.User? myUser = await SupabaseHandler.getUser(
        response.user?.id ?? "",
      );
      provider.saveUser(myUser);
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
            (routeName) => false,
      );
    } on AuthException catch (e) {
      Navigator.pop(context);
      DialogUtils.showMassageDialog(
        context: context,
        massage: e.message,
        posTitle: StringsManger.ok.tr(),
        posClick: () {
          Navigator.pop(context);
        },
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
}
