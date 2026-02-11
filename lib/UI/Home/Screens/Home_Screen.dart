import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharmago/UI/splash/screens/splash_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, SplashScreen.routeName);
          },
          icon: Icon(Icons.logout),
        ),
      ),
    );
  }
}
