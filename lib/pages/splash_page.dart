import 'package:chat_app/api/api.dart';
import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      //exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white),
      );
      if (APIs.auth.currentUser != null) {
        print("\n user ${FirebaseAuth.instance.currentUser}");
        //navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      } else {
        //navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        );
      }
    });
  }

  Widget build(BuildContext context) {
    //meidaQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          //
          Positioned(
            width: 120,
            height: 120,
            bottom: 400,
            right: 135,
            child: Image.asset(
              "images/chat.png",
            ),
          ),
          //button
          const Positioned(
              width: 350,
              height: 50,
              bottom: 100,
              left: 57,
              child: Text(
                "Let's have a goog conversation 💚",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.pink,
                    letterSpacing: 1.4,
                    fontSize: 19,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }
}
//2 mit 12th video