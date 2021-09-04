import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplify/helpers/drawer.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:simplify/screens/activity.dart';
import 'package:simplify/screens/friends.dart';
import 'package:simplify/screens/groups.dart';
import 'package:simplify/screens/new_friend.dart';
import 'package:simplify/screens/new_group.dart';
import 'package:simplify/screens/new_transaction.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MainScreen extends StatelessWidget {
  MainScreen(this.user);
  final User user;

  // Map<String, dynamic>? data;

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'tokens': token,
    });
  }

  Future<void> seeToken() async {
    // Assume user is logged in for this example
    String? token = await FirebaseMessaging.instance.getToken();
    print("token execution =========");
    print(token);
    if (token == null || token == '') return;
    DocumentSnapshot u = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    // Save the initial token to the database
    if (token != u['tokens']) saveTokenToDatabase(token);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  @override
  Widget build(BuildContext context) {
    seeToken();

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // print(snapshot.data.data());
          if (snapshot.hasError) {
            return Text('Something went wrong' + snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: const Color.fromRGBO(5, 18, 44, 1),
              child: Center(
                child: CircularProgressIndicator(
                ),
              ),
            );
          }
          // if(snapshot.data!=null){
          Map<String, dynamic>? data = snapshot.data!.data();
          return MainContent(data: data, user: user);
        });
  }
}

class MainContent extends StatefulWidget {
  const MainContent({
    Key? key,
    required this.data,
    required this.user,
  }) : super(key: key);

  final Map<String, dynamic>? data;
  final User user;

  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent>
    with SingleTickerProviderStateMixin {
  static const List<String> _tabs = ['Activity', 'Friends', 'Groups'];

  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
      // print("Selected Index: " + _tabController.index.toString());
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // if (message.notification != null) {
      //   print('Message also contained a notification: ${message.notification}');
      // }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // if (_selectedIndex == 2)
            
          Container(
            decoration:  BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => NewTransaction(
                              data: widget.data!,
                              uid: widget.user.uid,
                              isEdit: false,
                              groupAdd: false,
                            )));
              },
              iconSize: 50,
              splashColor: Colors.deepOrange,
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
          child: CustomDrawer(
        data: widget.data,
        uid: widget.user.uid,
        isHome: true,
      )),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                  actions: [
                    Builder(
                        builder: (context) => GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 125),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Hi ' +
                                            widget.data!['name'].split(" ")[0],
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(right: 22, left: 12),
                                    width: 37.0,
                                    height: 37,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: new NetworkImage(
                                            widget.data!['img']),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                  ],
                  systemOverlayStyle:
                      Theme.of(context).appBarTheme.systemOverlayStyle,
                  backwardsCompatibility:
                      Theme.of(context).appBarTheme.backwardsCompatibility!,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ' SIMPLIFY.',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                  pinned: true,
                  backgroundColor:
                      Theme.of(context).appBarTheme.backgroundColor,
                  elevation: Theme.of(context).appBarTheme.elevation,
                  iconTheme: IconThemeData(
                    color: Colors.black,
                  ),
                  collapsedHeight: 70,
                  expandedHeight: 380.0,
                  flexibleSpace: MainUpper(widget.data!),
                  forceElevated: innerBoxIsScrolled,
                  bottom: ColoredTabBar(
                    TabBar(
                      indicatorWeight: 0.9,
                      controller: _tabController,
                      tabs: _tabs
                          .map((String name) => Tab(
                                child: Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                          color: Colors.white, fontSize: 18),
                                ),
                              ))
                          .toList(),
                    ),
                  )),
            ),
          ];
        },
        body: TabBarView(controller: _tabController, children: [
          Activity(widget.user.uid, widget.data!),
          Friends(widget.data!, widget.user.uid),
          Groups(widget.data!, widget.user.uid),
        ]),
      ),
    );
  }
}

class MainUpper extends StatelessWidget {
  MainUpper(this.data);
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    num geta = 0;
    num pay = 0;
    (data['friends'] as List).forEach((elm) {
      if (elm['value'] < 0) {
        pay = pay - elm['value'];
      } else {
        geta = geta + elm['value'];
      }
    });
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 90),
      padding: const EdgeInsets.only(top: 30, left: 30, right: 15),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Balance",
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.grey,
                  fontFamily: "Inter",
                )),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "${data['currencyCode']} " + (geta - pay).toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 68,
                  color: Color.fromRGBO(5, 18, 44, 0.9),
                  fontWeight: FontWeight.w700,
                  fontFamily: "Inter",
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("You are owed",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                            fontFamily: "Inter",
                          )),
                      SizedBox(height: 5),
                      FittedBox(
                        child: Text("${data['currencyCode']} " + (geta).toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                              color: Colors.green[800],
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("You owe",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                            fontFamily: "Inter",
                          )),
                      SizedBox(height: 5),
                      FittedBox(
                        child: Text("${data['currencyCode']} " + pay.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                              color: Colors.red[700],
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.tabBar);

  // final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        // height: 50,
        padding: const EdgeInsets.only(top: 10, right: 70),
        decoration: const BoxDecoration(
          //  boxShadow: [const BoxShadow(
          //   color:  Color.fromRGBO(5, 18, 44, 0.4),
          //   blurRadius: 20.0,
          // ),],
          color: Color.fromRGBO(5, 18, 44, 1),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),

        child: tabBar,
      );
}
