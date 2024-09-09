import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Components/custom_snackBar.dart';
import '../Components/loading.dart';
import '../colors.dart';
import '../comman_var.dart';
import 'customer_home_page.dart';
import 'manager_home_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  TextEditingController searchController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isObscure = true;
  bool? rememberMe = false;

  List<Post> _posts = [];


  signInUser()async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Allowing you to login...'),
    );

    final User? userFirebase = (await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).catchError((errorMsg){
      Navigator.pop(context);
      showCustomSnackBar(context,
          message: 'Incorrect email or password!',
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    })
    ).user;

    if(!context.mounted)return;
    Navigator.pop(context);

    if(userFirebase != null){
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(userFirebase.uid);
      userRef.once().then((snap){
        if(snap.snapshot.value!=null){
          if((snap.snapshot.value as Map)['blockStatus']=='no'){
            userName = (snap.snapshot.value as Map)['name'];
            userEmail = (snap.snapshot.value as Map)['email'];
            Navigator.of(context)
                .pushNamed('/home');

          }
          else{
            showCustomSnackBar(context,
                message: 'You are blocked, Contact admin!',
                backgroundColor: Colors.redAccent,
                textColor: Colors.white,
                icon: Icons.error);

            FirebaseAuth.instance.signOut();

          }

        }
        else{

          showCustomSnackBar(context,
              message: 'Your record do not exist as user..',
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              icon: Icons.error);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    DatabaseReference postsRef = FirebaseDatabase.instance.ref().child('posts');
    DatabaseEvent event = await postsRef.once();

    if (event.snapshot.exists) {
      final postsData = Map<String, dynamic>.from(event.snapshot.value as Map);
      final List<Post> loadedPosts = [];
      postsData.forEach((postId, postData) {
        // Convert postData to a Map and then to a Post object
        final post = Post.fromMap(Map<String, dynamic>.from(postData), postId);
        loadedPosts.add(post);

        // Assuming 'photos' is a List<String> of image URLs in your Post model
        if (post.photos.isNotEmpty) {
          print("Image URLs for Post $postId: ${post.photos}");
        } else {
          print("No image URLs found for Post $postId");
        }
      });

      setState(() {
        _posts = loadedPosts;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.appBarColor,
        toolbarHeight: 85.0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'SPAR Product Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 300,
              height: 60,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                controller: searchController,
                onChanged: (String value) {
                  // Implement your filtering logic here if needed
                },
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search, color: Colors.white),
                  hintText: 'Search',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:10.0),
              child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'View Details',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:10.0),
              child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Share Your',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            )
          ],
        ),


        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 25),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/signup');
                  // Action when button is pressed
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16,color: Colors.black,),
                ),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(120, 20),
                  backgroundColor: Colors.white, // Set the background color to green
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(30), // Set the border radius
                  ),
                ),
              ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 25),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
                // Action when button is pressed
              },
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 16,color: Colors.white,),
              ),
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(120, 20),
                backgroundColor: Colors.blue, // Set the background color to green
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(30), // Set the border radius
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 25),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: SingleChildScrollView(
                        child: Container(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Glad you are back.!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  style: TextStyle(color: Colors.white),
                                  onEditingComplete: () {
                                    // Define what you want to do when editing is complete. For example:
                                    FocusScope.of(context).nextFocus(); // Move focus to the next field
                                  },
                                  controller: emailController,
                                  onChanged: (String value) {
                                    // Implement your filtering logic here if needed
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email',
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
                                  style: TextStyle(color: Colors.white),
                                  onSubmitted: (String value) {
                                    ();
                                  },
                                  controller: passwordController,
                                  onChanged: (String value) {
                                    // Implement your filtering logic here if needed
                                  },
                                  obscureText:
                                  isObscure, // Set the obscureText property
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isObscure =
                                          !isObscure; // Toggle between show and hide password
                                        });
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
                                Row(
                                  children: [
                                    Theme(
                                      data: ThemeData(
                                        unselectedWidgetColor: Colors
                                            .white, // Set the border color to white
                                      ),
                                      child: Checkbox(
                                        value: rememberMe,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            rememberMe = newValue ??
                                                false; // Set the new value or default to false
                                          });
                                        },
                                        checkColor: Colors.white,
                                        activeColor: Colors.transparent,
                                      ),
                                    ),
                                    Text(
                                      "Remember Me",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 25),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        signInUser();
                                        // Action when button is pressed
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(240, 40),
                                        backgroundColor: Colors
                                            .blue, // Set the background color to green
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              30), // Set the border radius
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed('/forget-password');
                                      },
                                      child: Text(
                                        "Forget Password?",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      )),
                                ),

                                SizedBox(
                                  height: 15,
                                ),
                                Divider(
                                  height: 2,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  height: 15,
                                ),

                                Center(
                                    child: Image.asset(
                                      'images/google.png',
                                      width: 240,
                                    )),

                                SizedBox(
                                  height: 15,
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Do you haven't account? ",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed('/signup');
                                      },
                                      child: Text(
                                        "Signup",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                )

                                // Container(
                                //   margin: EdgeInsets.all(10),
                                //   width: 240,
                                //   decoration: BoxDecoration(
                                //     image: DecorationImage(
                                //       image:/ Replace with your image path
                                //       fit: BoxFit.cover, // Adjust the BoxFit as needed
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          width: 500,
                          height: 600,
                        )
                      ),
                    );
                  },
                );
              },
              child: const Text(
                'Post Your Item',
                style: TextStyle(fontSize: 16,color: Colors.white,),
              ),
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(160, 20),
                backgroundColor: Colors.amberAccent, // Set the background color to green
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(30), // Set the border radius
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(25),
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.teal, // Teal color background
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.lightBlue, // Light blue border color
                      width: 3, // Border width
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF005255), // Left side color
                        Color(0xFF00C7C7), // Right side color
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Find the Best Products',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
        
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Discover the World of Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Replace your existing ListView.builder with this GridView.builder
            Container(
              margin: EdgeInsets.symmetric(horizontal: 25),
              height: MediaQuery.of(context).size.height, // You might want to adjust this
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Number of columns
                  crossAxisSpacing: 10.0, // Spacing between the columns
                  mainAxisSpacing: 10.0, // Spacing between rows
                ),
                itemCount: _posts.length, // The count of posts to display
                itemBuilder: (context, index) {
                  final post = _posts[index]; // Access the current post in the loop
                  return InkWell(
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            child: SingleChildScrollView(
                                child: Container(
                                  color: Colors.black,
                                  child: Padding(
                                    padding: const EdgeInsets.all(50.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 36,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Glad you are back.!',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextField(
                                          style: TextStyle(color: Colors.white),
                                          onEditingComplete: () {
                                            // Define what you want to do when editing is complete. For example:
                                            FocusScope.of(context).nextFocus(); // Move focus to the next field
                                          },
                                          controller: emailController,
                                          onChanged: (String value) {
                                            // Implement your filtering logic here if needed
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Enter your email',
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
                                          style: TextStyle(color: Colors.white),
                                          onSubmitted: (String value) {
                                            signInUser();
                                          },
                                          controller: passwordController,
                                          onChanged: (String value) {
                                            // Implement your filtering logic here if needed
                                          },
                                          obscureText:
                                          isObscure, // Set the obscureText property
                                          decoration: InputDecoration(
                                            hintText: 'Enter your password',
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isObscure =
                                                  !isObscure; // Toggle between show and hide password
                                                });
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
                                        Row(
                                          children: [
                                            Theme(
                                              data: ThemeData(
                                                unselectedWidgetColor: Colors
                                                    .white, // Set the border color to white
                                              ),
                                              child: Checkbox(
                                                value: rememberMe,
                                                onChanged: (bool? newValue) {
                                                  setState(() {
                                                    rememberMe = newValue ??
                                                        false; // Set the new value or default to false
                                                  });
                                                },
                                                checkColor: Colors.white,
                                                activeColor: Colors.transparent,
                                              ),
                                            ),
                                            Text(
                                              "Remember Me",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 25),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                signInUser();
                                                // Action when button is pressed
                                              },
                                              child: const Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                fixedSize: const Size(240, 40),
                                                backgroundColor: Colors
                                                    .blue, // Set the background color to green
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      30), // Set the border radius
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pushNamed('/forget-password');
                                              },
                                              child: Text(
                                                "Forget Password?",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              )),
                                        ),

                                        SizedBox(
                                          height: 15,
                                        ),
                                        Divider(
                                          height: 2,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),

                                        Center(
                                            child: Image.asset(
                                              'images/google.png',
                                              width: 240,
                                            )),

                                        SizedBox(
                                          height: 15,
                                        ),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Do you haven't account? ",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pushNamed('/signup');
                                              },
                                              child: Text(
                                                "Signup",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )

                                        // Container(
                                        //   margin: EdgeInsets.all(10),
                                        //   width: 240,
                                        //   decoration: BoxDecoration(
                                        //     image: DecorationImage(
                                        //       image:/ Replace with your image path
                                        //       fit: BoxFit.cover, // Adjust the BoxFit as needed
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  ),
                                  width: 500,
                                  height: 600,
                                )
                            ),
                          );
                        },
                      );
                    },
                    child: GridTile(
                      child: Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(post.model, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            // Example of displaying the first photo if available
                            if (post.photos.isNotEmpty)
                              Expanded(
                                child: Image.network(post.photos.first, fit: BoxFit.cover),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

        
          ],
        ),
      ),

    );
  }
}
