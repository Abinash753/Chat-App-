import 'dart:io';

import 'package:chat_app/api/api.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../helper/dialogs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(microseconds: 1000));
    setState(() {
      isAnimate = true;
    });
  }

//handle google login button click
  _handleGoogleBtnClick() {
    //this code shows progress bar
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      //this code hiding progress bar
      Navigator.pop(context);
      if (user != null) {
        //check wheter user exists or not
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        } else {
          //if user is new then create new user
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomePage(),
              ),
            );
          });
        }
      }
    });
  }

  //google sign
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
//trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      //obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      //create a new credential
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      //once signed in, return the user credentials
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print("\n_signInWithGoogle: $e ");
      Dialogs.showSnackbar(
          context, "Something went wromg, Check internet connection");
    }
    return null;
  }

  //sign out function
  _signOut() async {
    await APIs.auth.signOut();
    await GoogleSignIn().signOut();
  }

  Widget build(BuildContext context) {
    //meidaQuery = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Login Page",
        ),
        backgroundColor: Colors.grey,
      ),
      body: Stack(
        children: [
          //
          AnimatedPositioned(
            width: 120,
            height: 120,
            top: 230,
            right: isAnimate ? 135 : 50,
            duration: const Duration(seconds: 1),
            child: Image.asset(
              "images/chat.png",
            ),
          ),
          //button
          Positioned(
              width: 300,
              height: 50,
              bottom: 100,
              left: 57,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 72, 224, 194),
                      shape: const StadiumBorder(),
                      elevation: 1),
                  onPressed: () {
                    _handleGoogleBtnClick();
                  },
                  icon: Image.asset(
                    "images/google.png",
                    height: 40,
                  ),
                  label: const Text(
                    "Signin with google",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 19),
                  ))),
        ],
      ),
    );
  }
}
