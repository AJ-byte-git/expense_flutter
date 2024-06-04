import 'package:expense_app/UI/Pages/Sign_in_page.dart';
import 'package:expense_app/UI/Pages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder:(context, snapshot){
          if(snapshot.hasData){
            return const main_page();
          }
          else{
            return const Sign_In_Page();
          }
        },
      ),
    );
  }
}
