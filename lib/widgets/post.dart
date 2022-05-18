import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/comments.dart';
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
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;

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
  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      setState(() {
        likeCount += 1;
        isLiked = true;
        showHeart = true;
        likes[currentUserId] = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

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
      onDoubleTap: () => handleLikePost(),
      child: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Column(children: <Widget>[
          description == ""
              ? SizedBox()
              : Row(
                  children: [
                    Expanded(
                        child: Text(description,
                            style: TextStyle(
                                fontFamily: "Brand-Regular",
                                fontSize: 15,
                                color: NetworkColors.colorGrey))),
                  ],
                ),
          SizedBox(
            height: 10,
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              mediaUrl == null
                  ? circularProgress()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 0.1,
                            offset: Offset(0, 0.1),
                            spreadRadius: 0.2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(mediaUrl)),
                    ),
              showHeart
                  ? Animator(
                      duration: Duration(milliseconds: 2000),
                      tween: Tween(begin: 0.8, end: 150.0),
                      curve: Curves.elasticOut,
                      cycles: 0,
                      builder: (BuildContext context,
                              AnimatorState animatorState, Widget child) =>
                          Transform.scale(
                            scale: animatorState.value,
                            child: Icon(
                              Icons.favorite,
                              size: 150,
                              color: NetworkColors.colorGrey,
                            ),
                          ))
                  : Text("")
              // showHeart
              //     ? Icon(
              //         Icons.favorite,
              //         size: 150,
              //         color: NetworkColors.colorGrey,
              //       )
              //     : Text("")
            ],
          ),
        ]),
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
              onTap: () => handleLikePost(),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
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
              onTap: () => showComments(context,
                  postId: postId, ownerId: ownerId, mediaUrl: mediaUrl),
              child: Icon(
                Icons.chat_outlined,
                size: 28.0,
                color: NetworkColors.colorGrey,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 6.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2.0,
              offset: Offset(0, 1),
              spreadRadius: 0.9,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildPostHeader(),
            buildPostImage(),
            buildPostFooter(),
          ],
        ),
      ),
    );
    ;
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMedialUrl: mediaUrl,
    );
  }));
}
