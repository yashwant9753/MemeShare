import 'package:flutter/material.dart';
import 'package:socialnetwork/widgets/post.dart';

import '../pages/post_screen.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PostScreen(postId: post.postId, userId: post.ownerId)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 0.1,
              ),
            ],
          ),
          child: Image.network(post.mediaUrl),
        ),
      ),
    );
  }
}
