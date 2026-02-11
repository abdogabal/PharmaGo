
import 'package:flutter/material.dart';

import '../Models/User.dart';

class UserProvider extends ChangeNotifier {
  User? myUser;

  saveUser(User? newUser) {
    myUser = newUser;
    notifyListeners();
  }
}
