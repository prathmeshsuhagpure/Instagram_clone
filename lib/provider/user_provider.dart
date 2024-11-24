import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:insta_supabase/resources/auth_methods.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser => _user;

  Future<void> refreshUser() async {
    try {
      User? user = await _authMethods.getUserDetails();
      if (user != null) {
        _user = user;
        notifyListeners();
      } else {
        log("Failed to refresh user: user details are null");
      }
    } catch (e) {
      log("Error refreshing user: $e");
    }
  }
}
