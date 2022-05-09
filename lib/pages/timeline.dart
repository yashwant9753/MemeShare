import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/widgets/header.dart';
import 'package:socialnetwork/widgets/progress.dart';
import 'package:firebase_core/firebase_core.dart';

final CollectionReference usersRef =
    FirebaseFirestore.instance.collection('users');

class TimeLine extends StatefulWidget {
  const TimeLine({Key key}) : super(key: key);

  @override
  State<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  // List<dynamic> users = [];                                      1

  @override
  void initState() {
    // TODO: implement initState

    // getUsers();
    // getUserByDocId();
    // createUser();
    // updateUser();
    // deleteUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header("MemeShare"),
      body: StreamBuilder<QuerySnapshot>(
          // Realtime data patch
          stream: usersRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            final List<Text> children =
                snapshot.data.docs.map((doc) => Text(doc["name"])).toList();

            return Container(
              child: ListView(children: children),
            );
          }),

      // body: FutureBuilder<QuerySnapshot>(                 //future doesn't collect data in RealTime
      //   future: usersRef.get(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData) {
      //       return circularProgress();
      //     }
      //     final List<Text> children =
      //         snapshot.data.docs.map((doc) => Text(doc['name'])).toList();

      //     return Container(
      //       child: ListView(
      //         children: children,
      //       ),
      //     );
      //   },
      // )

      // Container(                                                        1
      //   child: ListView(
      //     children: users.map((user) => Text(user["name"])).toList(),
      //   ),
      // )
    );
  }
}

















/////*****Create Delete Update retrieve Data Query ********////////



// createUser() {
  //   usersRef
  //       .doc("dwadawd")
  //       .set({"name": "Jeff", "postcount": 0, "isAdmin": "True"});
    // usersRef.add({

    //   "name": "Jeff",
    //   "postcount":0,
    //   "isAdmin":"True"
    // });
  // }

  // updateUser() async {
  //   final DocumentSnapshot doc =
  //       await usersRef.doc("4tii7h8NRG4thGZNMeOc").get();
  //   print(doc);
  //   if (doc.exists) {
  //     doc.reference.update({"name": "John", "postcount": 2, "isAdmin": "True"});
  //   }
  // }

  // deleteUser() async {
  //   final DocumentSnapshot doc = await usersRef.doc("dwadawd").get();
  //   if (doc.exists) {
  //     doc.reference.delete();
  //   }
  // }

  // getUsers() async {
  //   final QuerySnapshot snapshot = await usersRef.get();
    // setState(() {                                                1
    //   users = snapshot.docs;
    // });
    // final QuerySnapshot snapshot = await usersRef
    //     // .where("isAdmin", isEqualTo: "True")
    //     // .where("postcount", isEqualTo: 2)
    //     // .orderBy("postcount", descending: true)
    //     .limit(1)
    //     .get();

    // snapshot.docs.forEach((element) {
    //   print(element.data());
    // });

    // usersRef.get().then((snapshot) {
    //   snapshot.docs.forEach((doc) {
    //     print(doc.data());
    //     print(doc.id);
    //     print(doc.exists);
    //   });
    // });
  // }

  // getUserByDocId() async {
  //   final String id = "kZoIJw9CgfRNdMOD7u6Q";
  //   final DocumentSnapshot doc = await usersRef.doc(id).get();
  //   print(doc.data());
  //   print(doc.id);
  //   print(doc.exists);
  // }