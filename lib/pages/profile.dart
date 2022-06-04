import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/edit_profile.dart';
import 'package:socialnetwork/pages/home.dart';
import 'package:socialnetwork/pages/show_followers.dart';
import 'package:socialnetwork/pages/show_followings.dart';
import 'package:socialnetwork/widgets/header.dart';
import 'package:socialnetwork/widgets/post.dart';
import 'package:socialnetwork/widgets/post_tile.dart';
import 'package:socialnetwork/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false; // default
  final String currentuserId = currentUser?.id; // Assign Current user ID
  bool isLoading = false; // Loading
  String postOrientation = "grid"; // Orientation
  int postCount = 0; // count the user post
  List<Post> posts = []; // Fetch the user posts from post class

  int followerCount = 0; // Number of followers
  int followingCount = 0; // Number of Following

  getProfilePosts() async {
    // Get Profile Id user All post and add into post list
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  /// Count Column
  Column buildCountColumn(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontFamily: "Brand-Regular",
              fontWeight: FontWeight.normal,
              color: Colors.grey),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          '$count',
          style: TextStyle(fontFamily: "Brand-Bold", fontSize: 14),
        ),
      ],
    );
  }

//// Profile builder
  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return linearProgress();
        }
        User user = User.fromDocument(snapshot.data);

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: NetworkColors.colorDarkBlue,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(user.photoUrl),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                user.displayName,
                style: TextStyle(fontFamily: "Brand-Bold", fontSize: 17),
              ),
              Text(
                '@${user.username}',
                style: TextStyle(
                    fontFamily: "Brand-Regular",
                    fontWeight: FontWeight.normal,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  buildCountColumn("Memes", postCount),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowFollowings(
                                  currentUser: widget.profileId,
                                  followercCount: followingCount,
                                )),
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Following",
                          style: TextStyle(
                              fontFamily: "Brand-Regular",
                              fontWeight: FontWeight.normal,
                              color: Colors.grey),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '$followerCount',
                          style:
                              TextStyle(fontFamily: "Brand-Bold", fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // buildCountColumn("FOLLOWERS", followerCount),/
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowFollowers(
                                  currentUser: widget.profileId,
                                  followercCount: followerCount,
                                )),
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Follower",
                          style: TextStyle(
                              fontFamily: "Brand-Regular",
                              fontWeight: FontWeight.normal,
                              color: Colors.grey),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '$followerCount',
                          style:
                              TextStyle(fontFamily: "Brand-Bold", fontSize: 14),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${user.bio}',
                    style: TextStyle(fontFamily: "Brand-Regular", fontSize: 11),
                  )),
              Divider(
                height: 1,
                color: Colors.grey,
              ),
              buildTogglePostOrientation(),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No Meme",
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
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.picture_in_picture),
          color: postOrientation == 'grid' ? Colors.black : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list_alt_outlined),
          color: postOrientation == 'list' ? Colors.black : Colors.grey,
        ),
      ],
    );
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    getProfilePosts();
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .get();

    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection("userFollowing")
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(currentuserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  buildProfileButton() {
    // build appbar action button
    bool isprofileOwner = currentuserId == widget.profileId;

    if (isprofileOwner) {
      // for current user show edit iconButton
      return Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: IconButton(
          icon: Icon(Icons.edit_calendar_outlined),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditProfile(currentUserId: currentuserId)));
          },
        ),
      );
    } else {
      // and for other user follow or unfollow Button
      return Container(
          padding: EdgeInsets.all(8.0),
          child: isFollowing
              ? RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    "Unfollow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  color: NetworkColors.colorDarkBlue,
                  onPressed: () {
                    handleUnfollowUser();
                  },
                )
              : RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    "Follow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  color: NetworkColors.colorDarkBlue,
                  onPressed: () {
                    handleFollowUser();
                  },
                ));
    }
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentuserId)
        .set({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .doc(currentuserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentuserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "postId": "",
      "commentData": "",
      "mediaUrl": "",
      "userId": currentuserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timeStamp,
    });
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentuserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(currentuserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentuserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildButton(String text, Function function) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
      ),
      color: NetworkColors.colorDarkBlue,
      onPressed: () {
        function;
      },
    );
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  logoutOption(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Logout from MemeShare"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text(
                  "Logout",
                  style: TextStyle(fontSize: 17),
                ),
                onPressed: () {
                  logout();
                }),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 17),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: currentuserId == widget.profileId
            ? IconButton(
                icon: Icon(Icons.logout, color: Colors.red),
                onPressed: () {
                  logoutOption(context);
                })
            : IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                }),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.white70,
        title: Text(
          "Profile",
          style: TextStyle(
              fontFamily: 'Brand-Bold', fontSize: 20.0, color: Colors.black),
        ),
        actions: [
          buildProfileButton(),
        ],
      ),
      body: ListView(children: <Widget>[
        buildProfileHeader(),
        buildProfilePosts(),
      ]),
    );
  }
}
