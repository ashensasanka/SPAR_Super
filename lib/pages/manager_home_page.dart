import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:waste_management/pages/profile_popup.dart';
import '../colors.dart';
import '../comman_var.dart';
import '../commonMethods.dart';
import 'item_detail_manager_page.dart';
import 'landing_page.dart';
import 'manufa_details_page.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  TextEditingController searchController = TextEditingController();
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    getUserInfoAndCheckBlockStatus();
    _fetchPosts();
  }

  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(FirebaseAuth.instance.currentUser!.uid);

    await userRef.once().then(
      (snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)['blockStatus'] == 'no') {
            setState(() {
              userName = (snap.snapshot.value as Map)['name'];
              userEmail = (snap.snapshot.value as Map)['email'];
            });
          } else {
            snackBar(
                context, 'You are blocked, Contact admin!', Colors.redAccent);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LandingPage()),
            );
            FirebaseAuth.instance.signOut();
          }
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LandingPage()),
          );
        }
      },
    );
  }

  Future<void> _fetchPosts() async {
    DatabaseReference postsRef = FirebaseDatabase.instance.ref().child('posts');
    DatabaseEvent event = await postsRef.once();

    if (event.snapshot.exists) {
      final postsData = Map<String, dynamic>.from(event.snapshot.value as Map);
      final List<Post> loadedPosts = [];
      postsData.forEach(
        (postId, postData) {
          // Convert postData to a Map and then to a Post object
          final post =
              Post.fromMap(Map<String, dynamic>.from(postData), postId);
          loadedPosts.add(post);

          // Assuming 'photos' is a List<String> of image URLs in your Post model
          if (post.photos.isNotEmpty) {
            print("Image URLs for Post $postId: ${post.photos}");
          } else {
            print("No image URLs found for Post $postId");
          }
        },
      );
      setState(
        () {
          _posts = loadedPosts;
        },
      );
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
                'Product Management',
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
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'View Details',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Share Your',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          ],
        ),
        actions: [
          Text(
            userName,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ProfilePopUp();
                  },
                );
              },
              icon: Icon(
                Icons.person_pin,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/post-item');
              },
              child: const Text(
                'Add an Item',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(160, 20),
                backgroundColor:
                    Colors.amberAccent, // Set the background color to green
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(30), // Set the border radius
                ),
              ),
            ),
          )
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
                          'Find the SPAR products',
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
                            'Discover the Products in SPAR',
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
              height: MediaQuery.of(context)
                  .size
                  .height, // You might want to adjust this
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final posts =
                      _posts[index]; // Access the current post in the loop
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ManagerDetailsPage(post: posts),
                        ),
                      );
                    },
                    child: GridTile(
                      child: Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                posts.title,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    "Available Count: ${posts.available}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    "Sold Count: ${posts.sold}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    "Next Mounth Predictive Count: ${posts.predictive}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (posts.photos.isNotEmpty)
                              Expanded(
                                child: Image.network(
                                  posts.photos.first,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Image.network(
            //   "https://firebasestorage.googleapis.com/v0/b/rating-system-24f88.appspot.com/o/Images%2F180082%2F1711221829099?alt=media&token=5eedccc9-9f2f-4e97-9085-db4e9cb01f71",
            //   width: 50,
            //   scale: 1.0,
            //   height: 50,
            // ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final String itemId,
      itemType,
      title,
      description,
      price,
      deviceType,
      model,
      postID;
  final List<String> photos; // List of image URLs
  final double available, sold, predictive;

  Post(
      {required this.itemId,
      required this.itemType,
      required this.title,
      required this.description,
      required this.price,
      required this.deviceType,
      required this.model,
      required this.postID,
      required this.photos,
      required this.available,
      required this.sold,
      required this.predictive});

  // Factory constructor to create a Post instance from a Map
  factory Post.fromMap(Map<String, dynamic> map, String itemId) {
    return Post(
      itemId: itemId,
      itemType: map['itemType'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      deviceType: map['deviceType'] ?? '',
      model: map['model'] ?? '',
      postID: map['postID'] ?? '',
      photos: List<String>.from(map['photos'] ?? []),
      available: map['available'],
      sold: map['sold'],
      predictive: map['predictive'],
    );
  }
}
