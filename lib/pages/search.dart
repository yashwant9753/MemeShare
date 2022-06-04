import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:socialnetwork/models/user.dart';
import 'package:socialnetwork/networkColors.dart';
import 'package:socialnetwork/pages/activity_feed.dart';
import 'package:socialnetwork/pages/home.dart';
import 'package:socialnetwork/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  FocusNode searchFocus;

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where(
          "username",
          isGreaterThanOrEqualTo: query,
        )
        .get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: TextFormField(
        focusNode: searchFocus,
        controller: searchController,
        decoration: InputDecoration(
          focusColor: NetworkColors.colorDarkBlue,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NetworkColors.colorGrey,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.docs.forEach((doc) {
          User user = User.fromDocument(doc);
          if (user.id == currentUser.id) {
          } else {
            UserResult searchResult = UserResult(user);
            searchResults.add(searchResult);
          }
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchFocus = FocusNode();
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: NetworkColors.colorGrey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "@${user.username}",
                style: TextStyle(
                  color: NetworkColors.colorGrey,
                ),
              ),
            ),
          ),
          Divider(height: 2.0, color: Colors.black),
        ],
      ),
    );
  }
}
