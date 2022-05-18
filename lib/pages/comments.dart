import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/home.dart';
import 'package:socialnetwork/widgets/header.dart';
import 'package:socialnetwork/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMedialUrl;

  Comments({this.postId, this.postMedialUrl, this.postOwnerId});

  @override
  State<Comments> createState() => _CommentsState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMedialUrl: postMedialUrl);
}

class _CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMedialUrl;

  _CommentsState({this.postId, this.postMedialUrl, this.postOwnerId});

  /// fetchin data from comments collection and Create comment list in realtime
  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.docs.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  /// adding data in "comments" collection
  addComment() {
    commentsRef.doc(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentController.text,
      "timestamp": timeStamp,
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, title: "Comments"),

        /// header
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          color: Colors.white,
          margin: EdgeInsets.all(8.0),
          height: 60,

          /// TextField
          child: TextFormField(
            maxLines: 5,
            minLines: 1,
            controller: commentController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(width: 0)),
              hintText: "Type a message... ",
              prefixIcon: Icon(
                Icons.attach_file,
                size: 28.0,
              ),

              /// addcomment button
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  addComment();
                },
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: 70),
          child: buildComments(),
        ));
  }
}

/// Creating a ListTile for user Comments

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  /// Fetching users data from 'comments' collection
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
