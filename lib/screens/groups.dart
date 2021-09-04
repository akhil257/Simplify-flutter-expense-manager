import 'package:flutter/material.dart';
import 'package:simplify/screens/group_history.dart';

import 'new_group.dart';

class Groups extends StatelessWidget {
  Groups(this.data, this.uid);
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
            color: const Color.fromRGBO(5, 18, 44, 1),
            child: Builder(
              builder: (BuildContext context) {
                return CustomScrollView(
                  // key: PageStorageKey<String>(name),
                  slivers: <Widget>[
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                    ),
                    data['groups'].length <= 0
                        ? SliverPadding(
                            padding: const EdgeInsets.only(top: 45),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/group.png',
                                    height: 160,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Oh no! You are not in any group\nStart creating groups with added friends.",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                ],
                              ),
                            ))
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 4,
                            ),
                            sliver: SliverFixedExtentList(
                              itemExtent: 80.0,
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  var amt = data['groups'][index]['value'];
                                  Widget txt;

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
                                                  GroupHistory(
                                                      data['groups'][index],
                                                      uid,
                                                      data)));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 1),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            margin: EdgeInsets.only(right: 20),
                                            decoration: new BoxDecoration(
                                                border: Border.all(
                                                  width: 1.5,
                                                  color: data['groups'][index]
                                                              ['value'] <
                                                          0
                                                      ? Colors.red
                                                      : Colors.green.shade500,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Container(
                                              width: 57.0,
                                              height: 57,
                                              decoration: new BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                                image: new DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: new AssetImage(
                                                      'assets/images/' +
                                                          data['groups'][index]
                                                              ['img'] +
                                                          '.png'),
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
                                              Text(
                                                data['groups'][index]['name'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .copyWith(fontSize: 21),
                                              ),
                                              txt
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                childCount: data['groups'].length,
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
              margin: const EdgeInsets.only(right: 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              NewGroup(data, uid)));
                },
                child: Text(
                  'Create a Group',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
