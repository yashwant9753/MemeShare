import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/edit_profile.dart';
import 'package:socialnetwork/pages/home.dart';
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
  final String currentuserId = currentUser?.id;
  bool isLoading = false;
  String postOrientation = "grid";
  int postCount = 0;
  List<Post> posts = [];

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postRef
        .doc(currentuserId)
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
      future: userRef.doc(widget.profileId).get(),
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
              CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(user.photoUrl),
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
                  buildCountColumn("FOLLOWING", 2020),
                  buildCountColumn("FOLLOWERS", 2020),
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
        child: Center(
          child: ListView(
            shrinkWrap: true,
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
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post: post)));
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
    print("Yashwant");
    getProfilePosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          currentuserId == widget.profileId
              ? Padding(
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
                )
              : Container(
                  padding: EdgeInsets.all(8.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      "Follow",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                    color: NetworkColors.colorDarkBlue,
                    onPressed: () {},
                  ),
                ),
        ],
      ),
      body: ListView(children: <Widget>[
        buildProfileHeader(),
        buildProfilePosts(),
      ]),
    );
  }
}
