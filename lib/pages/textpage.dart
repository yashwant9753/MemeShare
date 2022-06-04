import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TestPage")),
      body: Container(
          child: Center(
        child: RaisedButton(
          child: Text("Pressed"),
          onPressed: () {},
        ),
      )),
    );
  }
}
