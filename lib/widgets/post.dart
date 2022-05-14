import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/home.dart';
import 'package:socialnetwork/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;
  Post(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.likeCount});
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    /// if not like return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;

    /// if the key is explicitly set to true add likes
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  State<Post> createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
        future: userRef.doc(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: NetworkColors.colorGrey,
              backgroundImage: NetworkImage(user.photoUrl),
            ),
            title: GestureDetector(
                onTap: () {},
                child: Text(
                  user.username,
                  style: TextStyle(fontFamily: "Brand-Bold"),
                )),
            subtitle: Text(location),
            trailing: IconButton(
              onPressed: () => print("deleting post"),
              icon: Icon(Icons.more_vert),
            ),
          );
        });
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => print("liking Post"),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          mediaUrl == null
              ? circularProgress()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(mediaUrl)),
                )
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () => print('liking post'),
              child: Icon(
                Icons.favorite_border,
                size: 28.0,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              "$likeCount",
              style: TextStyle(
                  fontFamily: "Brand-Regular",
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
            ),
            SizedBox(
              width: 50,
            ),
            GestureDetector(
              onTap: () => print('showing comments'),
              child: Icon(
                Icons.chat_outlined,
                size: 28.0,
                color: NetworkColors.colorGrey,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
                child: Text(
              description,
              style: TextStyle(fontFamily: "Brand-Regular"),
            ))
          ],
        ),
        SizedBox(
          height: 6.0,
        ),
        Divider(
          height: 5,
          color: NetworkColors.colorGrey,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        Divider(
          height: 2,
          color: NetworkColors.colorGrey,
        ),
        buildPostImage(),
        buildPostFooter()
      ],
    );
    ;
  }
}
