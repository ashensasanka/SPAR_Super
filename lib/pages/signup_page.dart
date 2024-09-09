import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:waste_management/auth_pages/learner_auth.dart';
import '../Components/custom_snackBar.dart';
import '../Components/glass_box.dart';
import '../Components/loading.dart';
import '../commonMethods.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isObscure = true;
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  CommonMethods cMethods = CommonMethods();

  var options = ['Customer', 'Manufacturer', 'Store Manager'];
  var role = "Customer";

  @override
  void dispose() {
    // Always remember to dispose of FocusNodes
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    signUpFormValidation();
  }

  signUpFormValidation() {
    if (userNameController.text.trim().length < 3) {
      showCustomSnackBar(context,
          message: 'Your name must be 4 or more characters',
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    } else if (!emailController.text.contains('@')) {
      showCustomSnackBar(context,
          message: 'Please enter a valid email',
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    } else if (passwordController.text.trim().length < 6) {
      showCustomSnackBar(context,
          message: 'Your password must be 6 or more characters',
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    } else if (confirmPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      showCustomSnackBar(context,
          message: 'Passwords do not match',
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    } else {
      registerNewUser();
      // Proceed with the sign-up process as all validations are passed
    }
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Registering your account...'),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
            .catchError(
      (errorMsg) {
        Navigator.pop(context);
        snackBar(
          context,
          errorMsg.toString(),
          Colors.red,
        );
      },
    ))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users').child(userFirebase!.uid);
    Map userDataMap = {
      "name": userNameController.text.trim(),
      "email": emailController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
      "role": role
    };
    userRef.set(userDataMap);

    CollectionReference ref_profile =
        FirebaseFirestore.instance.collection('users');
    ref_profile.doc(userFirebase!.uid).set(
      {
        "name": userNameController.text.trim(),
        "email": emailController.text.trim(),
        "id": userFirebase.uid,
        "blockStatus": "no",
        "role": role
      },
    );

    if (role == 'Customer') {
      Navigator.of(context).pushNamed('/customer');
    } else if (role == 'Manufacturer') {
      Navigator.of(context).pushNamed('/manufacturer');
    } else {
      Navigator.of(context).pushNamed('/manager');
    }
    showCustomSnackBar(context,
        message: 'Account created, you can Login now!',
        backgroundColor: Colors.green.shade500,
        textColor: Colors.white,
        icon: Icons.check_circle_outline_rounded);
  }

  signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    print(userCredential.user?.displayName);

    if (userCredential.user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  void showSuccessSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: Colors.green,
      content: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Account created successful! You can login now!',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: 'Undo',
        textColor: Colors.white,
        onPressed: () {},
      ),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showRequiredFieldsSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: const Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Please fill in all required fields',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      duration: Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showError(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: const Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Error',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      duration: Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showPasswordMismatchSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Passwords do not match',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      duration: Duration(seconds: 5),
      behavior: SnackBarBehavior.floating, // Make it floating
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // margin: EdgeInsets.all(20),
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              image: DecorationImage(
                image: AssetImage('images/background.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Roll the Carpet.!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 48,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              signInWithGoogle();
                              // Navigator.of(context).pushNamed('/welcome');
                              // Action when button is pressed
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(190, 40),
                              backgroundColor: Colors
                                  .blue, // Set the background color to green
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Text(
                                    'Skip the Signup',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassBox(
                          width: 500,
                          height: 600,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 10, 40, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Signup',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  'Glad you are back.!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  onEditingComplete: () {
                                    FocusScope.of(context).nextFocus();
                                  },
                                  controller: userNameController,
                                  onChanged: (String value) {
                                    // Implement your filtering logic here if needed
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'User Name',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 15),
                                    hintStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  onEditingComplete: () {
                                    // Define what you want to do when editing is complete. For example:
                                    FocusScope.of(context)
                                        .nextFocus(); // Move focus to the next field
                                  },
                                  controller: emailController,
                                  onChanged: (String value) {
                                    // Implement your filtering logic here if needed
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Your Email',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 15),
                                    hintStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  onEditingComplete: () {
                                    _confirmPasswordFocusNode.requestFocus();
                                  },
                                  controller: passwordController,
                                  onChanged: (String value) {},
                                  obscureText: isObscure,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(
                                          () {
                                            isObscure = !isObscure;
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        isObscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.remove_red_eye_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 15),
                                    hintStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  focusNode: _confirmPasswordFocusNode,
                                  onEditingComplete: () {
                                    // Define what you want to do when editing is complete. For example:
                                    // createUser(context);
                                  },
                                  controller: confirmPasswordController,
                                  onChanged: (String value) {
                                    // Implement your filtering logic here if needed
                                  },
                                  obscureText:
                                      isObscure, // Set the obscureText property
                                  decoration: InputDecoration(
                                    hintText: 'Confirm your password',
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(
                                          () {
                                            isObscure =
                                                !isObscure; // Toggle between show and hide password
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        isObscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.remove_red_eye_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 15),
                                    hintStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white, // Border color
                                        width: 1.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          5.0), // Border radius (optional)
                                    ),
                                    child: Center(
                                      child: DropdownButton<String>(
                                        dropdownColor: Color(0xff63676a),
                                        style: const TextStyle(),
                                        isDense: true,
                                        isExpanded: false,
                                        iconEnabledColor: Colors.white,
                                        focusColor: Colors.white,
                                        items: options.map(
                                          (String dropDownStringItem) {
                                            return DropdownMenuItem<String>(
                                              value: dropDownStringItem,
                                              child: Text(
                                                dropDownStringItem,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                        onChanged: (newValueSelected) {
                                          setState(
                                            () {
                                              role = newValueSelected!;
                                            },
                                          );
                                        },
                                        value: role,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 15),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        checkIfNetworkIsAvailable();
                                        // createUser(context);
                                        // Action when button is pressed
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(240, 40),
                                        backgroundColor: Colors
                                            .blue, // Set the background color to green
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              30), // Set the border radius
                                        ),
                                      ),
                                      child: const Text(
                                        'Signup',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 10,
                                ),
                                Divider(
                                  height: 2,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                // GestureDetector(
                                //   onTap: (){
                                //     signInWithGoogle();
                                //   },
                                //   child: Center(
                                //     child: Image.asset(
                                //       'images/google.png',
                                //       width: 240,
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Already Registered? ",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed('/login');
                                      },
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
