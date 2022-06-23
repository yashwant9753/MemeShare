import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/home.dart';
import 'package:socialnetwork/pages/profile.dart';
import 'package:socialnetwork/pages/search.dart';
import 'package:socialnetwork/widgets/header.dart';
import 'package:socialnetwork/widgets/post.dart';
import 'package:socialnetwork/widgets/progress.dart';

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final scrollController = ScrollController();
  List<Post> posts;
  List<String> followingList = [];
  bool _hasNext = true;
  int dataLimit = 10;
  QuerySnapshot startafter;

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelinRef
        .doc(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  // getTimeline() async {
  //   List<Post> posts;

  //   if (this.posts.isEmpty) {
  //     startafter = await timelinRef
  //         .doc(widget.currentUser.id)
  //         .collection('timelinePosts')
  //         .orderBy('timestamp', descending: true)
  //         .limit(dataLimit)
  //         .get();
  //     List<Post> posts =
  //         startafter.docs.map((doc) => Post.fromDocument(doc)).toList();
  //   } else {
  //     startafter = await timelinRef
  //         .doc(widget.currentUser.id)
  //         .collection('timelinePosts')
  //         .orderBy('timestamp', descending: true)
  //         .startAfter(startafter.docs)
  //         .limit(dataLimit)
  //         .get()
  //         .then((value) {
  //       value.docs.forEach((element) {
  //         Post post = Post.fromDocument(element);
  //         this.posts.add(post);
  //       });
  //     });
  //   }

  //   setState(() {});
  // }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(children: posts);
    }
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.docs.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Suggestions",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'Brand-Regular',
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: NetworkColors.colorBlack,
              ),
              Column(children: userResults),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text(
            "MemeShare",
            style: TextStyle(
                fontFamily: 'Brand-Bold', fontSize: 20.0, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: NetworkColors.colorDarkBlue,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
            onRefresh: () => getTimeline(), child: buildTimeline()));
  }
}
