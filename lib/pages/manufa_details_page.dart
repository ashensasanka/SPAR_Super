import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Components/custom_snackBar.dart';
import '../Components/loading.dart';
import '../comman_var.dart';
import '../function.dart';
import 'customer_home_page.dart';
import 'manager_home_page.dart';

class ManufactureDetailsPage extends StatefulWidget {
  final Post post;

  ManufactureDetailsPage({Key? key, required this.post}) : super(key: key);

  @override
  State<ManufactureDetailsPage> createState() => _ManufactureDetailsPageState();
}

class _ManufactureDetailsPageState extends State<ManufactureDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  List<Comment> _comments = [];
  List<Rating> _ratings = [];
  int currentRating = 0;

  String url = '';
  var data;
  String output = '20';

  double calculateAverageRating() {
    if (_ratings.isEmpty) return 0;

    double sum = 0;
    for (final rating in _ratings) {
      double value = double.tryParse(rating.ratingValue) ?? 0;
      sum += value; // Assumes ratingValue is already a percentage
    }

    return sum / _ratings.length; // Calculates the average percentage
  }

  @override
  void initState() {
    super.initState();
    loadComments();
    loadRatings();
  }

  void loadComments() async {
    DatabaseReference commentsRef =
        FirebaseDatabase.instance.ref().child("comments/${widget.post.postID}");

    DatabaseEvent event = await commentsRef.once();

    if (event.snapshot.exists) {
      Map<String, dynamic> commentsData =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      List<Comment> loadedComments = [];
      commentsData.forEach((key, data) {
        loadedComments.add(Comment.fromMap(Map<String, dynamic>.from(data)));
      });

      setState(() {
        _comments = loadedComments;
      });
    }
  }

  void loadRatings() async {
    DatabaseReference ratingsRef =
        FirebaseDatabase.instance.ref().child("ratings/${widget.post.postID}");

    DatabaseEvent event = await ratingsRef.once();

    if (event.snapshot.exists) {
      Map<String, dynamic> ratingsData =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      List<Rating> loadedRatings = [];
      ratingsData.forEach((key, data) {
        loadedRatings.add(Rating.fromMap(Map<String, dynamic>.from(data)));
      });

      setState(() {
        _ratings = loadedRatings;
      });
    }
  }

  createNewComment() async {
    url = 'http://127.0.0.1:5000/api?query=' + _commentController.text;
    data = await fetchdata(url);
    var decoded = jsonDecode(data);
    setState(() {
      output = decoded['output'];
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Posting your comment..."),
    );

    // Corrected reference to the post-specific comments
    DatabaseReference commentsRef =
        FirebaseDatabase.instance.ref().child("comments/${widget.post.postID}");

    Map<String, dynamic> commentDataMap = {
      "comment": _commentController.text, // Use the text from the controller
      "email": userEmail,
      "user": userName,
      "status": '1',
      "pres": output
      // Add other details as needed
    };

    try {
      // Using push().set() to add a new comment without overwriting existing ones
      await commentsRef.push().set(commentDataMap);

      Navigator.pop(context); // Close the loading dialog
      showCustomSnackBar(context,
          message: 'Your comment added successfully!',
          backgroundColor: Colors.green.shade500,
          textColor: Colors.white,
          icon: Icons.check_circle_outline_rounded);
      _commentController.clear();
      loadComments();
    } catch (error) {
      Navigator.pop(context); // Close the loading dialog
      showCustomSnackBar(context,
          message: 'Failed to add your comment. Please try again.',
          backgroundColor: Colors.red.shade500,
          textColor: Colors.white,
          icon: Icons.error);
    }
  }

  createNewRating() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Submitting your rating..."),
    );

    DatabaseReference ratingsRef =
        FirebaseDatabase.instance.ref().child("ratings/${widget.post.postID}");

    Map<String, dynamic> ratingDataMap = {
      "ratingValue":
          _ratingController.text, // Use the text from the rating controller
      "email": userEmail,
      "user": userName,
      "status": '1',
      // Add other details as needed
    };

    try {
      await ratingsRef.push().set(ratingDataMap);

      Navigator.pop(context);
      loadRatings();
      calculateAverageRating();
      setState(() {
        currentRating = 0;
      });
      showCustomSnackBar(context,
          message: 'Your rating has been added successfully!',
          backgroundColor: Colors.green.shade500,
          textColor: Colors.white,
          icon: Icons.check_circle_outline_rounded);
      _ratingController.clear();
      // Reload ratings if you have a method for it
    } catch (error) {
      Navigator.pop(context); // Close the loading dialog
      showCustomSnackBar(context,
          message: 'Failed to add your rating. Please try again.',
          backgroundColor: Colors.red.shade500,
          textColor: Colors.white,
          icon: Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<double> allValues = [];
    // Calculate the average rating
    double averageRatingPercentage = calculateAverageRating();
    // Calculate the sum of all pres values
    double sumPres = 0;
    for (var comment in _comments) {
      double presValue = double.tryParse(comment.pres) ?? 0;
      allValues.add(presValue);
      sumPres += presValue;
    }
    // Calculate the average pres value
    double averagePres = allValues.isEmpty ? 0 : (sumPres / allValues.length);
    double averagePres1 = averagePres * 100;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(50),
              child: PageView.builder(
                itemCount: widget.post.photos.length,
                itemBuilder: (context, index) {
                  return Image.network(widget.post.photos[index],
                      fit: BoxFit.cover);
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Model: ${widget.post.model}',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(
                      height: 5,
                    ),
                    Text('(Device Type: ${widget.post.deviceType})',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Type: ${widget.post.itemType}',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Price:  Rs.${(widget.post.price)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Requesting Amount:  ${(widget.post.predictive)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '${widget.post.description}',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Comments: ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      height: 150,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _comments.isNotEmpty
                                ? ListView.builder(
                                    itemCount: _comments.length,
                                    itemBuilder: (context, index) {
                                      String stringValue =
                                          _comments[index].pres;
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Text(
                                              "${_comments[index].user} : ",
                                              style: TextStyle(
                                                  color: Colors
                                                      .blueAccent.shade700,
                                                  fontSize: 14),
                                            ),
                                            Text(
                                              _comments[index].comment,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text('No comments yet'),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                            child: LinearProgressIndicator(
                              value: averagePres,
                              backgroundColor: Colors.red,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                  'Positive : ${averagePres1.toStringAsFixed(2)} %'),
                              SizedBox(
                                width: 380,
                              ),
                              Text('Nagative'),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text('Average Rating:',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 3,
                          child: buildStars(averageRatingPercentage),
                        ),
                        // ...
                      ],
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    Text('Ratings: ',
                        style: TextStyle(
                          fontSize: 18,
                        )),

                    Container(
                      height: 100,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _ratings.isNotEmpty
                                ? ListView.builder(
                                    itemCount: _ratings.length,
                                    itemBuilder: (context, index) {
                                      double ratingValue = double.tryParse(
                                              _ratings[index].ratingValue) ??
                                          0;
                                      return ListTile(
                                        title: Text(
                                          "${_ratings[index].user}:",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        subtitle: buildStars(
                                            ratingValue), // Convert rating value to percentage
                                      );
                                    },
                                  )
                                : Center(child: Text('No ratings yet')),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating ~/ 20; // Each full star represents 20%
    int halfStars = (rating % 20) >= 10
        ? 1
        : 0; // If remainder is 10% or more, show a half star
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber));
    }
    if (halfStars == 1) {
      stars.add(Icon(Icons.star_half, color: Colors.amber));
      fullStars++; // Include the half star in the count
    }
    for (int i = fullStars; i < 5; i++) {
      stars.add(Icon(Icons.star_border, color: Colors.amber));
    }
    return Row(children: stars);
  }
}

class Comment {
  String user;
  String comment;
  String pres;

  Comment({required this.user, required this.comment, required this.pres});

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
        user: data['user'] ?? '',
        comment: data['comment'] ?? '',
        pres: data['pres'] ?? '');
  }
}

class Rating {
  String user;
  String email;
  String ratingValue;
  String status;

  Rating(
      {required this.user,
      required this.email,
      required this.ratingValue,
      required this.status});

  factory Rating.fromMap(Map<String, dynamic> data) {
    return Rating(
      user: data['user'] ?? '',
      email: data['email'] ?? '',
      ratingValue: data['ratingValue'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
