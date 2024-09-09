import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
String? userEmail;
String? imageUrl;

Future<User?> signInWithGoogle() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // This should include your databaseURL
  );

  User? user;

  if (kIsWeb) {
    GoogleAuthProvider authProvider = GoogleAuthProvider();

    try {
      final UserCredential userCredential = await _auth.signInWithPopup(authProvider);
      user = userCredential.user;
    } catch (e) {
      print(e);
    }
  } else {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount !=null){
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken
      );

      try {
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        user = userCredential.user;
      } on FirebaseException catch (e){
        if (e.code == 'account-exists-with-different-credential') {
          print('The account already exists with a different Credentials');
        } else if (e.code == 'invalid-credential'){
          print('object');
        }
      } catch (e){
        print(e);
      }
    }
  }

  if (user != null) {
    uid = user.uid;
    name = user.displayName;
    userEmail = user.email;
    imageUrl = user.photoURL;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth',true);
  }

  return user;
}

void SignOutGoogle() async {
  await googleSignIn.signOut();
  await _auth.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);

  uid = null;
  name = null;
  userEmail = null;
  imageUrl = null;
}

final FirebaseAuth _auth = FirebaseAuth.instance;

String? uid;
String? name;

Future<User?> registerWithEmailPassword(String email, String password) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // This should include your databaseURL
  );

  User? user;

  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

    user = userCredential.user;

    if (user!=null) {
      uid = user.uid;
      userEmail = user.email;
    }
  } catch (e){
    print(e);
  }
  return user;
}

Future<User?> signInWithEmailPassword (String email, String password) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // This should include your databaseURL
  );

  User? user;

  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

    user = userCredential.user;

    if (user!=null) {
      uid = user.uid;
      userEmail = user.email;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth', true);
    }
  } catch (e){
    print(e);
  }
  return user;
}

Future<String> signOut() async {
  await _auth.signOut();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);

  uid = null;
  userEmail =null;

  return 'User sign out';
}

Future getUser() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // This should include your databaseURL
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool authSignedIn = prefs.getBool('auth') ?? false;

  final User? user = _auth.currentUser;

  if (authSignedIn == false) {
    if (user!= null) {
      uid = user.uid;
      name = user.displayName;
      userEmail = user.email;
      imageUrl = user.photoURL;
    }
  }
}