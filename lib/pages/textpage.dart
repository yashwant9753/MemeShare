import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/models/country.dart';
import 'package:socialnetwork/pages/home.dart';
import 'package:socialnetwork/widgets/post.dart';

class TestPage extends StatefulWidget {
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final CollectionReference testRef =
      FirebaseFirestore.instance.collection("test");
  final db = FirebaseFirestore.instance;
  var data;
  final user = {
    "firstName": "Yashwant",
    "middleName": "Kumar",
    "lastName": "Sahu",
    "age": 23,
    "born": 1999,
    'testRef': ['Bami', 'Gandai', 'Bemetara', 'Durg']
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TestPage")),
      body: Container(
          child: Center(
        child: Column(
          children: [
            RaisedButton(
              child: Text("Add"),
              onPressed: () async {},
            ),
            RaisedButton(
              child: Text("Print"),
              onPressed: () async {
                testRef.doc('"SF').get().then(
                  (value) {
                    final biggerThanSf =
                        testRef.orderBy("population").startAt([value]);
                  },
                );
              },
            ),
            RaisedButton(
              child: Text("Remove"),
              onPressed: () async {
                testRef
                    .doc("userDetails")
                    .update({"age": FieldValue.increment(2)});
              },
            ),
            RaisedButton(
              child: Text("Update"),
              onPressed: () async {},
            ),
            RaisedButton(
              child: Text("Delete"),
              onPressed: () async {
                final data = <String, dynamic>{
                  "middleName": FieldValue.delete()
                };
                await testRef
                    .doc("userDetails")
                    .collection("subuserDetails")
                    .doc("userName")
                    .update(data);
              },
            ),
          ],
        ),
      )),
    );
  }
}
