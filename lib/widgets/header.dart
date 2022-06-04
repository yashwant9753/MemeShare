import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false,
    String titleText,
    removeBackButton = false,
    titleCenter = true}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    title: Text(
      isAppTitle ? "MemeShare" : titleText,
      style: TextStyle(
          fontFamily: 'Brand-Bold', fontSize: 20.0, color: Colors.black),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: titleCenter,
  );
}
