import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:waste_management/pages/home_page.dart';
import 'package:waste_management/pages/landing_page.dart';
import 'package:waste_management/pages/login_page.dart';
import 'package:waste_management/pages/signup_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // This should include your databaseURL
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        // '/welcome': (context) => LandingPage(),
        // '/forget-password': (context) => ForgetPWPage(),
        // '/home': (context) => HomePage(),
        // '/post-item': (context) => PostItemPage(),
      },
      home: FirebaseAuth.instance.currentUser == null ? LandingPage() :HomePage(),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // Use your custom scrollbar here or return the child directly to use the default scrollbar
    return child;
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad
    // Add other device kinds as needed
  };
}