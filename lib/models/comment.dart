class Comment {
  final comments;
  final String postId;
  final String username;
  final String userId;
  final DateTime datePublished;
  final String profileImage;


  const Comment({
    required this.comments,
        required this.postId,
        required this.username,
        required this.userId,
        required this.datePublished,
        required this.profileImage,
  });

  // Convert User object to JSON format for inserting into Supabase
  Map<String, dynamic> toJson() =>
      {
        "comments": comments,
        "username": username,
        "userId": userId,
        "postId": postId,
        "datePublished": datePublished.toIso8601String(),
        "profileImage": profileImage,
      };

  // Convert JSON data from Supabase to a User object
  factory Comment.fromJson(Map<String, dynamic> json) =>
      Comment(
        comments: json["comments"],
        username: json["username"],
        userId: json["userId"],
        postId: json["postId"],
        datePublished: json["datePublished"],
        profileImage: json["profileImage"],
      );

  // Creating a User object from Supabase data response
  static Comment fromSupabase(Map<String, dynamic> data) {
    return Comment(
        comments: data["comments"],
        username: data["username"],
        userId: data["userId"],
        postId: data["postId"],
        datePublished: data["datePublished"],
        profileImage: data["profileImage"],
    );
  }
}
