import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

  class PrefsManager {
  static late SharedPreferences prefs;

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }
  static void setTheme(bool currentTheme){
    prefs.setBool("theme", currentTheme);
  }
  static bool getTheme(){
    return prefs.getBool('theme')??false;
  }
  static onboardingFirstTime() {
    prefs.setBool('FirstTime', false);
  }

  static bool onboardingActive() {
    return prefs.getBool('FirstTime') ?? true;
  }
}
