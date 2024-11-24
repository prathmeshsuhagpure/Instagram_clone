class User {
  final String email;
  final String id;
  final String photoUrl;
  final String username;
  final String bio;
  // final List followers;
  // final List following;

  const User({
    required this.email,
    required this.id,
    required this.photoUrl,
    required this.username,
    required this.bio,
    // required this.followers,
    // required this.following,
  });

  // Convert User object to JSON format for inserting into Supabase
  Map<String, dynamic> toJson() => {
    "email": email,
    "id": id,
    "username": username,
    "bio": bio,
    "photoUrl": photoUrl,
    // "followers": followers,
    // "following": following,
  };

  // Convert JSON data from Supabase to a User object
  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json["email"],
    id: json["id"],  // Supabase uses 'id' as the column name here
    username: json["username"],
    bio: json["bio"],
    photoUrl: json["photoUrl"],
    // followers: List.from(json["followers"] ?? []),
    // following: List.from(json["following"] ?? []),
  );

  // Creating a User object from Supabase data response
  static User fromSupabase(Map<String, dynamic> data) {
    return User(
      email: data["email"],
      id: data["id"],
      photoUrl: data["photoUrl"],
      username: data["username"],
      bio: data["bio"],
      // followers: List.from(data["followers"] ?? []),
      // following: List.from(data["following"] ?? []),
    );
  }
}
