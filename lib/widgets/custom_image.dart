import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:socialnetwork/networkColors.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: CachedNetworkImage(
      imageUrl: mediaUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Padding(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(NetworkColors.colorDarkBlue),
        ),
        padding: EdgeInsets.all(50.0),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    ),
  );
}
