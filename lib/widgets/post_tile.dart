import 'package:flutter/material.dart';
import 'package:socialnetwork/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("Showing Post"),
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
