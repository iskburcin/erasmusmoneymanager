import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/bottom_navigation.dart';
import 'login_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        //listen to the authantication
        stream: FirebaseAuth.instance
            .authStateChanges(), //make us sure the user logged in
        builder: (context, snapshot) {
          //kullanıcı giriş yaptı
          if (snapshot.hasData) {
            return BottomNavigation();
          }

          //kullanıcı giriş yapılmadı
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
