import 'package:expense_app/auth/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Sign_In_Page extends StatefulWidget {
  const Sign_In_Page({super.key});

  @override
  State<Sign_In_Page> createState() => _Sign_In_PageState();
}

class _Sign_In_PageState extends State<Sign_In_Page> {
  bool _isChecked = false;

  void _onSignInButtonPressed() {
    if (_isChecked) {
      AuthService().signInWithGoogle();
    } else {
      Fluttertoast.showToast(
        msg: "Please agree to the terms and conditions",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _onCheckChanged(bool? newValue) {
    setState(() {
      _isChecked = newValue ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 30, top: 100, bottom: 10),
          child: Text(
            "Welcome!",
            style: TextStyle(fontSize: 30),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 0, 20),
          child: Text(
            "Please Sign-In to continue",
            style: TextStyle(fontSize: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 400, 30, 0),
          child: Row(
            children: <Widget>[
              Checkbox(value: _isChecked, onChanged: _onCheckChanged),
              const Expanded(
                  child: Text(
                "I agree to the terms and conditions of this application.",
                style: TextStyle(fontSize: 16),
              ))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
          child: SizedBox(
            width: (MediaQuery.of(context).size.width - 50),
            child: ElevatedButton(
              onPressed: _onSignInButtonPressed,
              child: const Text(
                "Sign In",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        )
      ],
    ));
  }
}
