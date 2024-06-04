import 'package:expense_app/auth/google_auth.dart';
import 'package:flutter/material.dart';
class Sign_In_Page extends StatelessWidget {
  const Sign_In_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: ()=> AuthService().signInWithGoogle(),
          child: const Text("Test"
          ),
        ),
      ),
    );
  }
}
