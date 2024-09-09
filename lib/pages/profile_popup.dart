import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../comman_var.dart';

class ProfilePopUp extends StatefulWidget {
  const ProfilePopUp({super.key});

  @override
  State<ProfilePopUp> createState() => _ProfilePopUpState();
}

class _ProfilePopUpState extends State<ProfilePopUp> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          right: 5,
          child: AlertDialog(
            content: SizedBox(
              height: 380,
              width: 350,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_circle_sharp,
                        size: 120,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        "$userName",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 180,
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            // createUser(context);
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => const ResetPasswordOne()),
                            // );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.blueGrey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(5), // Rounded corners
                            ),
                          ),
                          child: const Text(
                            'View Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 140,
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          onPressed: () async {
                            FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushNamed('/welcome');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.blueGrey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(5), // Rounded corners
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
