import 'package:flutter/material.dart';
import 'package:insta_supabase/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/colors.dart';
import 'package:insta_supabase/screens/signup_screen.dart'; // Import the signup screen

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkInitialAuthState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final initialAuthState = snapshot.data as AuthState;

            if (initialAuthState == AuthState.signedUp) {
              return const SignupScreen();
            } else if (initialAuthState == AuthState.loggedIn) {
              return const ResponsiveLayout(
                webScreenLayout: WebScreenLayout(),
                mobileScreenLayout: MobileScreenLayout(),
              );
            }
          } else {
            return const LoginScreen();
          }
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        return const LoginScreen(); // Fallback
      },
    );
  }

  Future<AuthState> _checkInitialAuthState() async {
    final session = Supabase.instance.client.auth.currentSession;

    // Check if there is a user session
    if (session != null) {
      return AuthState.loggedIn;
    } else {
      final isFirstLaunch = await _isFirstLaunch();
      return isFirstLaunch ? AuthState.signedUp : AuthState.loggedOut;
    }
  }

  Future<bool> _isFirstLaunch() async {
    // You can use shared_preferences to check if it's the first launch
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      prefs.setBool('isFirstLaunch', false);
    }

    return isFirstLaunch;
  }
}

enum AuthState { signedUp, loggedIn, loggedOut }
