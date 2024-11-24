import 'package:flutter/material.dart';
import 'package:insta_supabase/screens/add_post_screen.dart';
import 'package:insta_supabase/screens/home_screen.dart';
import 'package:insta_supabase/screens/search_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/profile_screen.dart';

final id = Supabase.instance.client.auth.currentUser!.id;
const webScreenSize = 600;

var homeScreenItems = [
  const HomeScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Text("Notification"),
  ProfileScreen(id: id),
];
