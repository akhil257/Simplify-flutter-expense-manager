
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simplify/helpers/privacy.dart';
import 'package:simplify/helpers/about.dart';
import 'package:simplify/screens/new_friend.dart';
import 'package:simplify/screens/new_transaction.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer(
      {Key? key, required this.data, required this.uid, required this.isHome})
      : super(key: key);

  final Map<String, dynamic>? data;
  final String uid;
  final bool isHome;

  _launchURL() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.techmonks.simplify';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("launch failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(data);
    return Container(
      color: Color.fromRGBO(5, 18, 44, 1),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            margin: const EdgeInsets.only(left: 5, top: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 20),
                    decoration: new BoxDecoration(
                      border: Border.all(
                        width: 1.6,
                        color: Colors.green.shade500,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 108.0,
                      height: 108,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.contain,
                          image: new NetworkImage(data!['img']),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                                              child: Text(
                          data!['name'],
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontSize: 22),
                        ),
                      ),
                      if (data!['email'] != null && data!['email'] != "")
                        FittedBox(
                                                  fit: BoxFit.scaleDown,

                                                  child: Text(
                            data!['email'],
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ),
                      if (data!['phone'] != null && data!['phone'] != "")
                        FittedBox(
                                                  fit: BoxFit.scaleDown,

                                                  child: Text(
                            data!['phone'],
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          isHome
              ? ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => NewTransaction(
                                  data: data!,
                                  uid: uid,
                                  isEdit: false,
                                  groupAdd: false,
                                )));
                  },
                  leading: Icon(
                    Icons.description,
                    color: Colors.white60,
                    size: 26,
                  ),
                  title: Text(
                    'Add Bill',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.white70),
                  ),
                )
              : ListTile(
                  onTap: () {
                    Navigator.popUntil(context, ModalRoute.withName("/"));
                  },
                  leading: Icon(
                    Icons.home_rounded,
                    color: Colors.white60,
                    size: 26,
                  ),
                  title: Text(
                    'Home',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.white70),
                  ),
                ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => NewFriend(
                            user: {
                              'value': 0,
                              'uid': uid,
                              'name': data!['name'],
                              'img': data!['img'],
                              'email': data!['email'],
                              'phone': data!['phone']
                            },
                            friendsList: data!['friends'],
                          )));
            },
            leading: Icon(
              Icons.person_add_alt,
              color: Colors.white60,
              size: 26,
            ),
            title: Text(
              'Add Friend',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white70),
            ),
          ),
          ListTile(
            onTap: () async {
              Share.share(
                  'Hey! Checkout this new app for sharing and spliting bills. Simplify - Split bills with Friends and in Groups \nhttps://play.google.com/store/apps/details?id=com.techmonks.simplify',
                  subject: 'A new app! Simplify');
            },
            leading: Icon(
              Icons.share,
              color: Colors.white60,
              size: 26,
            ),
            title: Text(
              'Share',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white70),
            ),
          ),
          ListTile(
            onTap: () {
              _launchURL();
            },
            leading: Icon(
              Icons.rate_review_rounded,
              color: Colors.white60,
              size: 26,
            ),
            title: Text(
              'Feedback',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white70),
            ),
          ),
          ListTile(
            onTap: (){ Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Privacy()));},
            leading: Icon(
              Icons.privacy_tip_rounded,
              color: Colors.white60,
              size: 26,
            ),
            title: Text(
              'Privacy Policy',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white70),
            ),
          ),
          ListTile(
            onTap: (){ Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => About()));},
            leading: Icon(
              Icons.policy,
              color: Colors.white60,
              size: 26,
            ),
            title: Text(
              'About Us',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white70),
            ),
          ),
          Spacer(),
          ListTile(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if(!isHome){
                Navigator.of(context).pop();
                Navigator.of(context).pop();}
            },
            leading: Icon(
              Icons.logout,
              color: Colors.white60,
              size: 26,
            ),
            title: Text(
              'Logout',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
