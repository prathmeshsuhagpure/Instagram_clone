import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_supabase/utils/colors.dart';
import 'package:insta_supabase/utils/global_variables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<List<Map<String, dynamic>>> _imagesStream;


  @override
  void initState() {
    super.initState();
    _imagesStream = fetchImagesStream();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: SvgPicture.asset(
                "assets/images/instagram.svg",
                color: primaryColor,
                height: 32,
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.messenger_outline,
                    color: primaryColor,
                  ),
                )
              ],
            ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _imagesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error in StreamBuilder: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('Snapshot data: ${snapshot.data}');
            return const Center(child: Text('No images found.'));
          } else {
            final images = snapshot.data!;
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width = 0.3 : 0,
                    vertical: width > webScreenSize ? 15 : 0,
                  ),
                  child: PostCard(
                        key: UniqueKey(),
                        snap: images[index],
                      ),
                ));
          }
        },
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> fetchImagesStream() {
    return Supabase.instance.client
        .from('posts')
        .stream(primaryKey: ['postId']).map((data) {
      return data.map<Map<String, dynamic>>((item) {
        return {
          'profileImage': item['profileImage'] ?? '',
          'username': item['username'] ?? 'Unknown User',
          'postUrl': item['postUrl'] ?? '',
          'description': item['description'] ?? 'Sample Description',
          'likes': item['likes'] ?? <String>[],
          'datePublished': item['datePublished'],
          'postId': item['postId'],
        };
      }).toList();
    }).handleError((error) {
      print('Error in fetchImagesStream: $error');
      throw Exception('Error fetching images stream: $error');
    });
  }
}
