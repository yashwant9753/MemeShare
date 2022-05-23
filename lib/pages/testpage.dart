import 'package:flutter/material.dart';

class TextPage extends StatefulWidget {
  const TextPage({Key key}) : super(key: key);

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  bool isFollowing = false;
  buildProfileButton() {
    // build appbar action button
    bool isprofileOwner = false;

    if (isprofileOwner) {
      // for current user show edit iconButton
      return Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: IconButton(
          icon: Icon(Icons.edit_calendar_outlined),
          onPressed: () {},
        ),
      );
    } else {
      // and for other user follow or unfollow Button
      return Container(
          padding: EdgeInsets.all(8.0),
          child: isFollowing
              ? RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "UnFollow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    print("unfollow");
                    setState(() {
                      isFollowing = false;
                    });
                  },
                )
              : RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "follow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    print("follow");
                    setState(() {
                      isFollowing = true;
                    });
                  },
                ));
    }
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
          buildProfileButton(),
        ],
      ),
      body: Center(
          child: Container(
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            isFollowing ? "Unfollow " : "Follow",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
          color: Colors.blue,
          onPressed: () {},
        ),
      )),
    );
  }
}
