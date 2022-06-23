import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/activity_feed.dart';
import 'package:socialnetwork/pages/create_account.dart';
import 'package:socialnetwork/pages/profile.dart';
import 'package:socialnetwork/pages/search.dart';
import 'package:socialnetwork/pages/textpage.dart';
import 'package:socialnetwork/pages/timeline.dart';
import 'package:socialnetwork/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google Signin Reference
final GoogleSignIn googleSignIn = GoogleSignIn();

/// Firebase FireStore user Reference
final CollectionReference usersRef =
    FirebaseFirestore.instance.collection("users");

/// Firebase FireStore Post Reference
final CollectionReference postsRef =
    FirebaseFirestore.instance.collection("posts");

/// Firebase FireStore comments  Reference
final CollectionReference commentsRef =
    FirebaseFirestore.instance.collection("comments");

/// Firebase FireStore activity   Reference
final CollectionReference activityFeedRef =
    FirebaseFirestore.instance.collection("feed");

/// Firebase FireStore follower   Reference
final CollectionReference followersRef =
    FirebaseFirestore.instance.collection("followers");

/// Firebase FireStore following   Reference
final CollectionReference followingRef =
    FirebaseFirestore.instance.collection("following");

/// Firebase FireStore timeline   Reference
final CollectionReference timelinRef =
    FirebaseFirestore.instance.collection("timeline");

/// Firebase FireStore Reference
final Reference storageRef = FirebaseStorage.instance.ref();

///Current Date and Time
final DateTime timeStamp = DateTime.now();

final GoogleSignInAccount user = googleSignIn.currentUser;

///current user
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();

  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    // Firebase.initializeApp();

    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });

      // configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection

      // if(currentUser.id == )
      // await followersRef
      //     .doc(user.id)
      //     .collection('userFollowers')
      //     .doc(user.id)
      //     .set({});
      doc = await usersRef.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
    
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          Search(),
          Upload(currentUser: currentUser),
          ActivityFeed(),
          Profile(profileId: currentUser?.id),
          TestPage()
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: NetworkColors.colorBlack,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.whatshot),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_camera, size: 35.0),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.text_snippet),
            ),
          ]),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      key: _scaffoldkey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.teal,
              Colors.purple,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "MemeShare",
              style: TextStyle(
                  fontFamily: 'Brand-Bold',
                  fontSize: 50.0,
                  color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 250,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset("images/google_logo.png"),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Sign in with Google",
                      style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 16),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
