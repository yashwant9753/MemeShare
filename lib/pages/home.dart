import 'dart:developer';
// import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/create_account.dart';
import 'package:socialnetwork/pages/pickfile.dart';
import 'package:socialnetwork/pages/profile.dart';
import 'package:socialnetwork/pages/search.dart';
import 'package:socialnetwork/pages/timeline.dart';
import 'package:socialnetwork/pages/upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final CollectionReference userRef =
    FirebaseFirestore.instance.collection("users");
final DateTime timeStamp = DateTime.now();

User currentUser;

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;

  PageController pageController;
  int pageIndex = 0;

  void initState() {
    Firebase.initializeApp();
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Error singing in: $err");
    });
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    });
  }

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

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exits by Id
    final GoogleSignInAccount user = googleSignIn.currentUser;

    DocumentSnapshot doc = await userRef.doc(user.id).get();

    // 2) if doesn't exits send create account page

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timeStamp
      });
      doc = await userRef.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              logout();
            },
            child: Text("Logout"),
          ),
          // TimeLine(),
          Search(),
          Upload(
            currentUser: currentUser,
          ),
          // ActivityFeed(),
          // Profile()
          PickFile()
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: NetworkColors.colorDarkBlue,
        height: 70,
        currentIndex: pageIndex,
        onTap: onTap,
        inactiveColor: NetworkColors.colorBlack,
        activeColor: NetworkColors.colorAccentWhite,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.add_a_photo,
            size: 40,
          )),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
          ),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.account_circle,
          )),
        ],
      ),
    );
    // return RaisedButton(
    //   onPressed: () {
    //     logout();
    //   },
    //   child: Text("Logout"),
    // );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Colors.teal,
              Colors.purple,
            ])),
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
                onTap: () {
                  login();
                },
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
                        style:
                            TextStyle(fontFamily: 'Brand-Bold', fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
