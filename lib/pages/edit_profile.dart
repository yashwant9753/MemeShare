import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/home.dart';
import 'package:socialnetwork/widgets/progress.dart';
import 'package:socialnetwork/widgets/snackBar.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            errorText: _displayNameValid ? null : "Display Name too Short",
            hintText: "Update Display Name",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Bio",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            errorText: _bioValid ? null : "Bio is too long",
            hintText: "Update Bio",
          ),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });
    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text
      });
      _scaffoldKey.currentState.showSnackBar(snackBar("Profile Updated"));
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.white70,
        title: Text(
          "Edit Profile",
          style: TextStyle(
              fontFamily: 'Brand-Bold', fontSize: 20.0, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              icon: Icon(Icons.done),
              tooltip: "Check Updated",
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 16.0,
                          bottom: 8.0,
                        ),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: NetworkImage(user.photoUrl),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton.icon(
                              label: Text(
                                "Logout",
                                style: TextStyle(color: Colors.white),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              color: Colors.red[900],
                              onPressed: () => logout(),
                              icon: Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                            ),
                            RaisedButton.icon(
                              label: Text(
                                "Update",
                                style: TextStyle(color: Colors.white),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              color: NetworkColors.colorDarkBlue,
                              onPressed: () => updateProfileData(),
                              icon: Icon(
                                Icons.update,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
