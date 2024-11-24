import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:insta_supabase/resources/auth_methods.dart';
import 'package:insta_supabase/resources/supabase_methods.dart';
import 'package:insta_supabase/screens/login_screen.dart';
import 'package:insta_supabase/utils/colors.dart';
import 'package:insta_supabase/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String id;

  const ProfileScreen({
    super.key,
    required this.id,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};

  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  final authServices = AuthMethods();

  void logout() async {
    await authServices.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUserId = supabase.auth.currentUser!.id;

      final userResponse = await Supabase.instance.client
          .from("users")
          .select()
          .eq("id", widget.id)
          .single();

      final postResponse = await Supabase.instance.client
          .from("posts")
          .select("*")
          .eq("id", widget.id);

      postLen = postResponse.length;

      if (userResponse != null) {
        userData = userResponse;

        // Safely handle the following field
        final followingRaw = userData["following"];
        final followingList = (followingRaw is String)
            ? jsonDecode(followingRaw) as List<dynamic>
            : followingRaw as List<dynamic>? ?? [];

        final followersRaw = userData["followers"];
        final followersList = (followersRaw is String)
            ? jsonDecode(followersRaw) as List<dynamic>
            : followersRaw as List<dynamic>? ?? [];

        followers = followersList.length;
        following = followingList.length;

        isFollowing = followersList.contains(currentUserId);
      }

      setState(() {});
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData["username"],
              ),
              centerTitle: false,
              actions: [
                IconButton(onPressed: logout, icon: const Icon(Icons.logout))
              ],
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData["photoUrl"]),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(postLen, "posts"),
                                    buildStatColumn(followers, "followers"),
                                    buildStatColumn(following, "following")
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Supabase.instance.client.auth.currentUser!
                                                .id ==
                                            widget.id
                                        ? FollowButton(
                                            text: "Edit Profile",
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            borderColor: Colors.grey,
                                            textColor: primaryColor,
                                            function: () {},
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                text: "Unfollow",
                                                backgroundColor: Colors.white,
                                                borderColor: Colors.grey,
                                                textColor: Colors.black,
                                                function: () async {
                                                  await SupabaseMethods()
                                                      .followUser(
                                                          Supabase
                                                              .instance
                                                              .client
                                                              .auth
                                                              .currentUser!
                                                              .id,
                                                          userData["id"]);
                                                  setState(() {
                                                    isFollowing = false;
                                                    followers--;
                                                  });
                                                },
                                              )
                                            : FollowButton(
                                                text: "Follow",
                                                backgroundColor: Colors.blue,
                                                borderColor: Colors.blue,
                                                textColor: Colors.white,
                                                function: () async {
                                                  await SupabaseMethods()
                                                      .followUser(
                                                    Supabase.instance.client
                                                        .auth.currentUser!.id,
                                                    userData["id"],
                                                  );
                                                  setState(() {
                                                    isFollowing = true;
                                                    followers++;
                                                  });
                                                },
                                              )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userData["username"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userData["bio"],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future:
                      supabase.from("posts").select("*").eq("id", widget.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                      return const Center(
                        child: Text('No posts yet!'),
                      );
                    }

                    /*print("snapshotData: $snapshot");*/

                    final data = snapshot.data! as dynamic;

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: data.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final post = data[index];

                        return Container(
                          child: Image(
                            image: NetworkImage(post["postUrl"]),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
