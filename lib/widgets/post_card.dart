import 'package:flutter/material.dart';
import 'package:insta_supabase/resources/supabase_methods.dart';
import 'package:insta_supabase/screens/comments_screen.dart';
import 'package:insta_supabase/utils/colors.dart';
import 'package:insta_supabase/utils/global_variables.dart';
import 'package:insta_supabase/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../provider/user_provider.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;
  //bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      final response = await Supabase.instance.client
          .from('comments') // Your 'comments' table
          .select('id')
          .eq('postId', widget.snap['postId']);

      if (response != null) {
        // Counting the number of comments by checking the length of the response data
        commentLen = response.length;
      } else {
        throw Exception('Error fetching comment count: $response');
      }
    } catch (err) {
      print("Error: ${err.toString()}");
    }
    setState(() {
     // isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime datePublished = DateTime.parse(widget.snap["datePublished"]);
    final user = Provider.of<UserProvider>(context).getUser!;
    final width = MediaQuery.of(context).size.width;

    return /*isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          )
        :*/ Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: width > webScreenSize
                    ? secondaryColor
                    : mobileBackgroundColor,
              ),
              color: mobileBackgroundColor,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                          .copyWith(right: 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.snap["profileImage"]),
                        radius: 16,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.snap['username'] ?? "unknown username",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: ListView(
                                padding: EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shrinkWrap: true,
                                children: [
                                  "Delete",
                                ]
                                    .map(
                                      (e) => InkWell(
                                        onTap: () async {
                                          SupabaseMethods().deletePost(
                                              widget.snap["postId"]);
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(e),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ); // Show Dialog
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () async {
                    setState(() {
                      isLikeAnimating = true;
                    });
                    await SupabaseMethods().likePost(
                        widget.snap["postId"], user.id, widget.snap["likes"]);
                    print('widget.snap["likes"]: ${widget.snap["likes"]}');
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: double.infinity,
                        child: Image.network(
                          widget.snap['postUrl'] ?? " no image",
                          fit: BoxFit.cover,
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isLikeAnimating ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: LikeAnimation(
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 120,
                          ),
                          isAnimating: isLikeAnimating,
                          duration: const Duration(milliseconds: 400),
                          onEnd: () {
                            setState(() {
                              isLikeAnimating = false;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Row(children: [
                  LikeAnimation(
                    isAnimating: widget.snap["likes"].contains(user.id),
                    smallLike: true,
                    child: IconButton(
                      onPressed: () async {
                        await SupabaseMethods().likePost(widget.snap["postId"],
                            user.id, widget.snap["likes"]);
                      },
                      icon: widget.snap["likes"].contains(user.id)
                          ? const Icon(Icons.favorite, color: Colors.red)
                          : const Icon(
                              Icons.favorite_border,
                            ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                                  snap: widget.snap,
                                )));
                      },
                      icon: const Icon(Icons.comment_outlined)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
                  Expanded(
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.bookmark_border))),
                  )
                ]),
                // Description and no of Comments
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w800),
                        child: Text(
                          "${widget.snap['likes'].length} likes",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: 8),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: primaryColor),
                            children: [
                              TextSpan(
                                text: widget.snap["username"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: "   ${widget.snap["description"]}",
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CommentsScreen(
                                        snap: widget.snap,
                                      )));
                            },
                            child: Text(
                              "View all $commentLen comments",
                              style: const TextStyle(
                                  fontSize: 16, color: secondaryColor),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          DateFormat.yMMMd().format(datePublished),
                          style: const TextStyle(
                              fontSize: 16, color: secondaryColor),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
