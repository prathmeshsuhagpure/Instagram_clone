class Post {
  final String description;
  final String id;
  final String postId;
  final String username;
  final DateTime datePublished;
  final String postUrl;
  final String profileImage;
  final likes;
  // final List followers;
  // final List following;

  const Post({
    required this.description,
    required this.id,
    required this.postUrl,
    required this.username,
    required this.profileImage,
    required this.postId,
    required this.likes,
    required this.datePublished,
    // required this.followers,
    // required this.following,
  });

  // Convert User object to JSON format for inserting into Supabase
  Map<String, dynamic> toJson() => {
    "description": description,
    "id": id,
    "username": username,
    "postUrl": postUrl,
    "postId": postId,
    "datePublished": datePublished.toIso8601String(),
    "profileImage": profileImage,
    "likes": likes
    // "followers": followers,
    // "following": following,
  };

  // Convert JSON data from Supabase to a User object
  factory Post.fromJson(Map<String, dynamic> json) => Post(
    description: json["description"],
    id: json["id"], // Supabase uses 'id' as the column name here
    username: json["username"],
    postUrl: json["postUrl"],
    postId: json["postId"],
    datePublished: json["datePublished"],
    profileImage: json["profileImage"],
    likes: json["likes"],
    // followers: List.from(json["followers"] ?? []),
    // following: List.from(json["following"] ?? []),
  );

  // Creating a User object from Supabase data response
  static Post fromSupabase(Map<String, dynamic> data) {
    return Post(
        description: data["description"],
        id: data["id"],
        username: data["username"],
        postUrl: data["postUrl"],
        postId: data["postId"],
        datePublished: data["datePublished"],
        profileImage: data["profileImage"],
        likes: data["likes"]
      // followers: List.from(data["followers"] ?? []),
      // following: List.from(data["following"] ?? []),
    );
  }
}
