import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Uploading image to Supabase storage
  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost) async {
    // Get the current user
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    // Generate a unique file path to avoid overwriting
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // If uploading a post, add the "posts" subfolder inside "user_data"
    String filePath;
    if (isPost) {
      String userId = user.id;

      // Generate a random ID for the post's subfolder (to store multiple posts in a unique subfolder)
      String randomId = const Uuid().v1();
      filePath = 'user_data/posts/$userId/$randomId.jpg';

    } else {
      filePath = 'user_data/Profile_pictures/${user.id}_$timestamp.jpg';
    }

    // Create a reference to the storage bucket
    final bucket = _supabase.storage.from('user_data');

    // Upload the file to the storage bucket
    final response = await bucket.uploadBinary(filePath, file);

    if (response.isEmpty) {
      throw Exception("Failed to upload image. Response was empty or null.");
    }

    // Generate the public URL to access the uploaded image
    final fileUrl = bucket.getPublicUrl(filePath);
    if (fileUrl.isEmpty) {
      throw Exception("Failed to generate public URL for the uploaded image.");
    }

    return fileUrl;
  }
}
