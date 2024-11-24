import 'dart:developer';
import 'dart:typed_data';
import 'package:insta_supabase/models/user.dart' as model;
import 'package:insta_supabase/resources/storage_methods.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthMethods {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetching User Details from Supabase
  Future<model.User?> getUserDetails() async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser != null) {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .single();
      return model.User.fromSupabase(response);
    }
    return null;
  }

  // Signup Method
  Future<String> signupUser({
    required String email,
    required String pass,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty &&
          pass.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        print("Inputs are valid");

        // Register User
        final authResponse = await _supabase.auth.signUp(
          email: email,
          password: pass,
        );

        // Upload Profile Picture
        String photoUrl = await StorageMethods()
            .uploadImageToStorage("Profile_pics", file, false);

        // Create User model instance
        model.User user = model.User(
          username: username,
          email: email,
          bio: bio,
          id: authResponse.user!.id,
          photoUrl: photoUrl,
        );

        // Add user to Supabase database
        final response =
            await _supabase.from("users").insert(user.toJson()).select();

        res = "Success";
        print("User added to Supabase: $res");

      }
    } catch (e) {
      print("Error: $e");
      log(e.toString());
      res = e.toString();
    }
    return res;
  }

  // Login Method
  Future<String> loginUser(
      {required String email, required String pass}) async {
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty || pass.isNotEmpty) {
        await _supabase.auth.signInWithPassword(password: pass, email: email);
        res = "Success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
