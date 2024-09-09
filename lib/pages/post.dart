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

  Post({
    required this.itemId,
    required this.itemType,
    required this.title,
    required this.description,
    required this.price,
    required this.deviceType,
    required this.model,
    required this.postID,
    required this.photos,
  });

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
    );
  }
}