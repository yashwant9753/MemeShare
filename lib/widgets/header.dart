import 'package:flutter/material.dart';

AppBar header(context, {String title, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
          fontFamily: 'Brand-Bold', fontSize: 20.0, color: Colors.white),
    ),
  );
}
