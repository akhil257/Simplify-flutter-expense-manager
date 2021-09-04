import 'package:flutter/material.dart';
import 'package:simplify/screens/friends_history.dart';

import 'new_friend.dart';

class Friends extends StatelessWidget {
  Friends(this.data, this.uid);
  final Map<String, dynamic> data;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        alignment: Alignment.center,
              children: [
                Container(
          color: Color.fromRGBO(5, 18, 44, 1),
          child: Builder(
            builder: (BuildContext context) {
              return CustomScrollView(
                slivers: <Widget>[
                  SliverOverlapInjector(
                    handle:
                        NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  ),
                  data['friends'].length <= 0
                      ? SliverPadding(
                          padding: const EdgeInsets.only(top: 50),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/friend.png',
                                  height: 160,
                                ),
                                Text(
                                  "Oh no! You dont have any friends\nStart searching for friend already on Simplify",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ))
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 4,
                          ),
                          sliver: SliverFixedExtentList(
                            itemExtent: 80.0,
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                Widget txt;
                                var amt = data['friends'][index]['value'];
                                if (amt < 0) {
                                  txt = Text(
                                      'You owe ${data['currencyCode']}' +
                                          amt.abs().toStringAsFixed(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w400));
                                } else {
                                  txt = Text(
                                    'You get ${data['currencyCode']}' +
                                        amt.abs().toStringAsFixed(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                            color: Colors.green[600],
                                            fontWeight: FontWeight.w400),
                                  );
                                }
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                FriendsHistory(
                                                    data,
                                                    data['friends'][index],
                                                    uid,
                                                    data['name'],
                                                    data['img'])));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 1),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          margin:
                                              const EdgeInsets.only(right: 20),
                                          decoration: new BoxDecoration(
                                            border: Border.all(
                                              width: 1.5,
                                              color: data['friends'][index]
                                                          ['value'] <
                                                      0
                                                  ? Colors.red
                                                  : Colors.green.shade500,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Container(
                                            width: 58.0,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                fit: BoxFit.cover,
                                                image: new NetworkImage(
                                                    data['friends'][index]
                                                        ['img']),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                data['friends'][index]['name'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .copyWith(fontSize: 21),
                                              ),
                                            ),
                                            txt,
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: data['friends'].length,
                            ),
                          ),
                        ),
                ],
              );
            },
          ),
        ),
        
      Positioned(
        bottom: 25,
        child: Container(
              height: 50,
              // width: double.infinity,
              margin: const EdgeInsets.only(right: 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => NewFriend(
                                user: {
                                  'value': 0,
                                  'uid': uid,
                                  'name': data['name'],
                                  'img': data['img'],
                                  'email':data['email'],
                                  'phone':data['phone'],
                                  'phoneCode':data['phoneCode']
                                },
                                friendsList:data['friends'],
                              )));
                },
                child: Text(
                  'Add new friend',
                ),
              ),
            ),
          )]),
    );
  }
}
