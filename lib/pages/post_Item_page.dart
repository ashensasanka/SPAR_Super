import 'dart:io';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_management/pages/profile_popup.dart';
import '../Components/custom_snackBar.dart';
import '../Components/loading.dart';
import '../colors.dart';
import 'package:http/http.dart' as http;
import '../comman_var.dart';
import '../commonMethods.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availableController = TextEditingController();

  String selectedItemCategory = '';
  String selectedBrand = '';

  CommonMethods cMethods = CommonMethods();

  List<XFile>? _imageFileList;
  List<String> _urlOfUploadedImages = [];

  String _currentId = Random().nextInt(999999).toString().padLeft(6, '0');

  Map<String, List<String>> categoryBrandMap = {
    'Baby Care': ['Pears Soap', 'Rebecaa Lee Baby Soap', 'Velona Cuddles Diaper'],
    'Bakery': ['Marshmallow Pack', 'Tea Bun','Cream Bun','Sandwich Bread','Seeni Sambal With Roast Paan'],
    'Beverages': ['Sprite 1050ml', 'Coca Cola 1050ml', 'Mountain Dew 1.5L'],
    'Chilled': ['Curd 110g', 'Richlife Set Kiri', 'Wattalappan 80g'],
    'Fresh Fruit': ['Pineapple', 'Papaya','Banana - Seeni','Jambola','Grapes - Black'],
    'Frozen': ['Kotmale Mozzarella Cheese 200g', 'Emborg Mozzarella Cheese Block 200g'],
    'Groceries': ['Rice','Biscuits','Suger & Sweetener','Cereals','Jams & Spread','Baking Aids','Honey & Jaggery','Eggs','Dried Fish','Flour','Grains','Jelly & Desserts','Meal kits','Noodles','Olives & Pickles','Pasta','Health Foods','Soups','Soya Meats','Spices & Seasonings','Sauces','Oil','Canned Food'],
    'Health & Beauty': ['Nsk Cotton Wool 30g', 'Dettol Liquid Small 60ml', 'Dettol Plaster 10S','First-Aid Kit'],
    'Household Items': ['Ph Matt Balloons Purple 12S', 'Balloons Red 9 Inch 20S','Keells Numeral Birthday Candle Red'],
    'Pet Care': ['Animox Animal Lotion 225ml', 'Can Can Shampoo Dog 125ml', 'Cp Dog Food Chicken 2kg','Furgard Dog Shampoo'],
    'Sweet & Snacks': ['Cappuccino Doughnut', 'Chocolate Croissant','Chocolate Muffin','Dark Chocolate Muffin'],
    // Add other categories and their brands
  };

  List<String> brandList = [];

  String generateNextPostId() {
    int currentIdInt = int.parse(_currentId);
    currentIdInt++;
    _currentId = currentIdInt.toString().padLeft(6, '0');
    print(_currentId);
    return _currentId;
  }

  void _pickImages() async {
    try {
      final List<XFile>? selectedImages = await ImagePicker().pickMultiImage(
        maxWidth: 500,
        maxHeight: 500,
      );
      if (selectedImages!.isNotEmpty) {
        setState(() {
          _imageFileList = selectedImages;
        });
      }
    } catch (e) {
      // Handle any errors
    }
  }

  Widget _buildImagePreview() {
    if (_imageFileList != null) {
      return SizedBox(
        height: 500.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageFileList!.length,
            itemBuilder: (context, index) {
              if (kIsWeb) {
                return Image.network(_imageFileList![index].path);
              } else {
                return Image.file(File(_imageFileList![index].path));
              }
            },
          ),
        ),
      );
    } else {
      return const Text("No images selected.");
    }
  }

  @override
  void initState() {
    super.initState();
    generateNextPostId();
  }

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    if (_imageFileList != null) {
      signUpFormValidation();
    } else {
      showCustomSnackBar(context,
          message: 'Please choose images first.',
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    }
  }

  signUpFormValidation() {
    if (_modelController.text.trim().length < 1) {
      showCustomSnackBar(context,
          message: "Model can't be empty!",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    } else if (_titleController.text.trim().length < 1) {
      showCustomSnackBar(context,
          message: "Title can't be empty!",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    } else if (_descriptionController.text.length < 1) {
      showCustomSnackBar(context,
          message: "Description can't be empty!",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    } else if (_priceController.text.trim().length < 1) {
      showCustomSnackBar(context,
          message: "Price can't be empty!",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          icon: Icons.error);
    } else {
      uploadImageToStorage();
    }
  }

  uploadImageToStorage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Uploading your Images..."),
    );

    if (_imageFileList != null && _imageFileList!.length <= 5) {
      for (var imageFile in _imageFileList!) {
        String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference referenceImage = FirebaseStorage.instance
            .ref()
            .child("Images/$_currentId/$imageIDName");

        if (kIsWeb) {
          final blob = await imageFile.readAsBytes();
          UploadTask uploadTask = referenceImage.putBlob(blob);
          TaskSnapshot snapshot = await uploadTask;
          String imageUrl = await snapshot.ref.getDownloadURL();
          setState(
                () {
              _urlOfUploadedImages.add(imageUrl);
            },
          );
        } else {
          UploadTask uploadTask = referenceImage.putFile(File(imageFile.path));
          TaskSnapshot snapshot = await uploadTask;
          String imageUrl = await snapshot.ref.getDownloadURL();
          setState(
                () {
              _urlOfUploadedImages.add(imageUrl);
            },
          );
        }
      }
      Navigator.pop(context);
      createNewPost();
    } else {
      showCustomSnackBar(
        context,
        message: 'Failed to upload your Images. Please try again.',
        backgroundColor: Colors.red.shade500,
        textColor: Colors.white,
        icon: Icons.error_outline,
      );
    }
  }

  createNewPost() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Posting your ad..."),
    );

    setState(() {
      available = double.parse(_availableController.text);
    });

    DatabaseReference postsRef =
    FirebaseDatabase.instance.ref().child("posts/$_currentId");
    Map<String, dynamic> postsDataMap = {
      "photos": _urlOfUploadedImages,
      "deviceType": selectedItemCategory,
      "itemType": _itemController.text.trim(),
      "model": _modelController.text.trim(),
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "price": _priceController.text.trim(),
      "postID": _currentId,
      "available":available,
      "predictive":predictive,
      "sold":sold
    };

    try {
      await postsRef.set(postsDataMap);
      Navigator.pop(context);

      showCustomSnackBar(context,
          message: 'Your post uploaded successfully!',
          backgroundColor: Colors.green.shade500,
          textColor: Colors.white,
          icon: Icons.check_circle_outline_rounded);
      Navigator.of(context).pushNamed('/manager');
    } catch (error) {
      Navigator.pop(context);

      showCustomSnackBar(context,
          message: 'Failed to upload your post. Please try again.',
          backgroundColor: Colors.red.shade500,
          textColor: Colors.white,
          icon: Icons.error_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.appBarColor,
        toolbarHeight: 85.0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Add New Items Page',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/manager');
              },
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(160, 20),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 300),
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Fill in the Product Details',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      color: Colors.teal),
                ),
                SizedBox(
                  height: 15,
                ),
                Divider(
                  thickness: 1,
                  endIndent: 50,
                  indent: 50,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 100),
                  child: Column(children: [
                    DropdownButtonFormField<String>(
                      value: selectedItemCategory.isEmpty
                          ? null
                          : selectedItemCategory,
                      onChanged: (newValue) {
                        setState(() {
                          selectedItemCategory = newValue ?? '';
                          brandList = categoryBrandMap[selectedItemCategory] ?? [];
                          selectedBrand = '';
                        });
                      },
                      items: categoryBrandMap.keys.map<DropdownMenuItem<String>>(
                            (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      hint: const Text('Category'),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedBrand.isEmpty ? null : selectedBrand,
                      onChanged: (newValue) {
                        setState(() {
                          selectedBrand = newValue ?? '';
                        });
                      },
                      items: brandList.map<DropdownMenuItem<String>>(
                            (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      hint: const Text('Brand'),
                    ),
                    // ... More DropdownButtonFormField widgets for each dropdown

                    TextField(
                      controller: _itemController,
                      decoration: const InputDecoration(labelText: 'Item Type'),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    TextField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Item Model (If have)'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Product Title'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      textAlign: TextAlign.left,
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration:
                      const InputDecoration(labelText: 'Description'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _priceController,
                      decoration:
                      const InputDecoration(labelText: 'Price (Rs)'),
                    ),
                    // Add photo buttons and other form fields
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _availableController,
                      decoration:
                      const InputDecoration(labelText: 'Product Adding Count'),
                    ),
                    _buildImagePreview(),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _pickImages();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.teal, // Set the background color
                      ),
                      child: const Text(
                        'Select Images',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Contact details section
                    Text(userName),
                    Text(userEmail),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.teal, // Set the background color
                      ),
                      child: const Text(
                        'Add Item',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          )),
    );
  }
}
