import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waste_management/pages/landing_page.dart';
import 'package:waste_management/pages/login_page.dart';
import 'package:waste_management/pages/manager_home_page.dart';
import 'package:waste_management/pages/manufa_home_page.dart';

import '../pages/customer_home_page.dart';

class LearnerAuthPage extends StatefulWidget {
  final String userType;
  LearnerAuthPage({Key? key, required this.userType});

  @override
  State<LearnerAuthPage> createState() => _LearnerAuthPageState();
}

class _LearnerAuthPageState extends State<LearnerAuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User is logged in
          if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user != null) {
              print(widget.userType);
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                builder: (context, documentSnapshot) {
                  if (documentSnapshot.hasData && documentSnapshot.data != null) {
                    String userRole = documentSnapshot.data!.get('role');
                    if (userRole == 'Customer') {
                      return const CustomerHomePage();
                    } else if (userRole == 'Manufacturer') {
                      return const ManufacHomePage();
                      // return VerifyEmailPage();
                    } else {
                      return const ManagerHomePage();
                    }
                  } else {
                    return Center(child: const CircularProgressIndicator()); // Handle loading state
                  }
                },
              );
            }
          }
          // User is not logged in
          // return LearnerLoginOrRegisterPage(userType: widget.userType);
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
