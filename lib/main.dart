import 'package:chat_app/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

//global object for accessing device screen size
late Size meidaQuery;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //to open application in full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    initializedFirebae();

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        //custome theme for appbar
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: Colors.black,
              letterSpacing: 1.3,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          elevation: 1,
          backgroundColor: Colors.greenAccent,
        ),
        //themes for icons
        iconTheme: const IconThemeData(color: Colors.black),
        primarySwatch: Colors.deepOrange,
      ),
      home: const SplashPage(),
    );
  }
}

// ...
initializedFirebae() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
    //<item name= "android.windowLayoutInDisplayCutoutMode">shortEdges</item> 