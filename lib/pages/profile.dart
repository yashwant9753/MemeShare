import 'package:flutter/material.dart';
import 'package:socialnetwork/widgets/header.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header("Profile"),
      body: Container(
        child: Text("this is timeline Page"),
      ),
    );
  }
}
