import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/pages/home.dart';
import 'package:socialnetwork/pages/search.dart';
import 'package:socialnetwork/widgets/header.dart';
import 'package:socialnetwork/widgets/progress.dart';

class ShowFollowers extends StatefulWidget {
  final String currentUser;
  final int followercCount;

  ShowFollowers({this.currentUser, this.followercCount});

  @override
  State<ShowFollowers> createState() => _ShowFollowersState();
}

class _ShowFollowersState extends State<ShowFollowers> {
  List<UserResult> userFollower = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getFollowers();
  }

  getFollower() {
    if (isLoading) {
      return circularProgress();
    }
    if (userFollower.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No Followers",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 30.0,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: userFollower,
    );
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.currentUser)
        .collection('userFollowers')
        .get();

    snapshot.docs.forEach((docs) async {
      if (docs.id == widget.currentUser) {
      } else {
        DocumentSnapshot doc = await usersRef.doc(docs.id).get();
        User user = User.fromDocument(doc);
        UserResult followers = UserResult(user);
        this.userFollower.add(followers);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            header(context, titleText: "Follower (${widget.followercCount})"),
        body: getFollower());
  }
}
