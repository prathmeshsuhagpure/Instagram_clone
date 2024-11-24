import 'package:flutter/material.dart';
import 'package:insta_supabase/provider/user_provider.dart';
import 'package:insta_supabase/resources/auth_gate.dart';
import 'package:insta_supabase/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import supabase package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fzmyqvgxthzjwhvxybzh.supabase.co',
    // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ6bXlxdmd4dGh6andodnh5YnpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzOTUzOTAsImV4cCI6MjA0Njk3MTM5MH0.3gpVHfa4DK1K6q9iU4PGzpwn_F0J3Fp5r2A2XjwClMg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark()
              .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
          home: const AuthGate()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body:
            Container() // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
