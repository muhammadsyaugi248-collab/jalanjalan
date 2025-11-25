import 'package:flutter/material.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/day34/views/login/login.dart';

class splashscreen2 extends StatefulWidget {
  const splashscreen2({super.key});

  @override
  State<splashscreen2> createState() => _splashscreen2State();
}

class _splashscreen2State extends State<splashscreen2> {
  @override
  void initState() {
    super.initState();
    isLoginFunction();
  }

  Future<void> isLoginFunction() async {
    Future.delayed(Duration(seconds: 3)).then((value) async {
      var isLogin = await PreferenceHandler.getLogin();
      print(isLogin);
      if (isLogin != null && isLogin == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Image.asset("assets/images/sp.png")),
          Text(
            "MPRO fake shop\nBy @itss_qyy",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
