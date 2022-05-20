import 'package:flutter/material.dart';

//// header function
AppBar header(context, {String title, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    centerTitle: true,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    shadowColor: Colors.white70,
    title: Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontFamily: 'Brand-Bold', fontSize: 20.0, color: Colors.black),
    ),
  );
}
