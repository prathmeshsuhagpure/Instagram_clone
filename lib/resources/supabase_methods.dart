import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:insta_supabase/models/post.dart';
import 'package:insta_supabase/resources/storage_methods.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseMethods {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload Post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String id,
    String username,
    String profileImage,
  ) async {
    String res = "Some Error Occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage("Posts", file, true);

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        id: id,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profileImage: profileImage,
        likes: [],
      );

      await _supabase.from("posts").insert(post.toJson()).select();

      res = "Success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String userId, List likes) async {
    try {
      if (likes.contains(userId)) {
        // Remove the user's like
        likes.remove(userId); // Modify the list locally
        await _supabase
            .from("posts")
            .update({"likes": likes}).eq('postId', postId);
        print("Removing like for user: $userId");
      } else {
        // Add the user's like
        likes.add(userId); // Modify the list locally
        await _supabase
            .from("posts")
            .update({"likes": likes}).eq('postId', postId);
        print("Added like for user: $userId");
      }
    } catch (e) {
      print("Error in likePost function: $e");
    }
  }

  Future<String> postComment(
    String postId,
    String text,
    String userId,
    String name,
    String profilePic,
  ) async {
    String res = "Some Error Occurred";
    final client = Supabase.instance.client;

    try {
      if (text.isNotEmpty) {
        // Prepare the data to be inserted
        final commentData = {
          'postId': postId,
          'comments': text,
          'userId': userId,
          'username': name,
          'photoUrl': profilePic,
          'datePublished': DateTime.now().toIso8601String(),
        };

        // Insert the comment into the 'comments' table
        await client.from('comments').insert(commentData);
        res = "success";

        //showSnackBar("Posted", context!);
        print("Comment added: $res");
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
      print(res);
    }
    return res;
  }

  Future<String> deletePost(String postId) async {
    String res = "Some Error Occurred";
    try {
      final response =
          await _supabase.from("posts").delete().eq("postId", postId).select();

      if (response != null) {
        res = "success";
        print("Post Deleted Successfully: $res");
      } else {
        print("Unable to delete post: $res");
      }
    } catch (err) {
      print("Error deleting post ${err.toString()}");
    }
    return res;
  }

  Future<void> followUser(String id, String followId) async {
    try {
      // Fetch the user's current following list
      final userResponse = await _supabase
          .from('users')
          .select('following')
          .eq('id', id)
          .single();

      if (userResponse.error != null) {
        throw userResponse.error!;
      }

      final following = userResponse['following'] as List?;

      // Check if the user is already following
      final isFollowing = following?.contains(followId) ?? false;

      // Update the user's following list
      final updatedFollowing = isFollowing
          ? following?.where((id) => id != followId).toList()
          : [...following ?? [], followId];

      await _supabase
          .from('users')
          .update({'following': updatedFollowing}).eq('id', id);

      // Update the followed user's followers list
      final followedUserResponse = await _supabase
          .from('users')
          .select('followers')
          .eq('id', followId)
          .single();

      if (followedUserResponse.error != null) {
        throw followedUserResponse.error!;
      }

      final followers = followedUserResponse['followers'] as List?;
      final updatedFollowers = isFollowing
          ? followers?.where((id) => id != id).toList()
          : [...followers ?? [], id];

      await _supabase
          .from('users')
          .update({'followers': updatedFollowers}).eq('id', followId);
    } catch (e) {
      print('Error following user: $e');
    }
  }
}

extension on PostgrestMap {
  get error => null;
}
