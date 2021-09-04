import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simplify/screens/view_bill.dart';
import 'package:intl/intl.dart';

class Activity extends StatelessWidget {
  Activity(this.uid, this.data);
  final String uid;
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: const Color.fromRGBO(5, 18, 42, 1),
        child: Builder(
          builder: (BuildContext context) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 4,
                  ),
                  sliver: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('transactions')
                          .where('users', arrayContains: uid)
                          .orderBy('createdAt', descending: true)
                          .limit(25)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return SliverToBoxAdapter(
                              child: Text('Something went wrong' +
                                  snapshot.error.toString()));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SliverToBoxAdapter(
                              child:
                                  Center(child: CircularProgressIndicator()));
                        }
                        var docs = snapshot.data!.docs;
                        return docs.length < 1
                            ? SliverPadding(
                                padding: const EdgeInsets.only(top: 80),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/activity.png',
                                        height: 90,
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Text(
                                        "No activity found \nStart adding friends, bills & groups",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ],
                                  ),
                                ))
                            : SliverFixedExtentList(
                                itemExtent: 88.0,
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    var who = docs[index]['createdBy'] == uid
                                        ? 'You'
                                        : docs[index]['createdByName'];
                                    var split = docs[index]['split'] as List;
                                    bool isGroup = docs[index]['isGroup'];
                                    Widget txt;
                                    if (split.length > 0) {
                                      var amt = split.firstWhere((element) =>
                                          element['uid'] == uid)['total'];
                                      if (amt < 0) {
                                        txt = Text(
                                            'You pay ${data['currencyCode']}' +
                                                amt.abs().toStringAsFixed(1),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .copyWith(
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.w400));
                                      } else {
                                        txt = Text(
                                          'You get back ${data['currencyCode']}' +
                                              amt.abs().toStringAsFixed(1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                  color: Colors.green[600],
                                                  fontWeight: FontWeight.w400),
                                        );
                                      }
                                    } else {
                                      txt = Text(
                                        'You get back ${data['currencyCode']}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.green[600]),
                                      );
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ViewBill(
                                                            data: data,
                                                            bill: docs[index],
                                                            uid: uid)));
                                      },
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 15, top: 3),
                                              width: 80,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    width: 52,
                                                    height: 54,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Image.asset(
                                                      'assets/images/' +
                                                          docs[index]
                                                              ['imageUrl'] +
                                                          '.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: -10,
                                                    left: 28,
                                                    child: Container(
                                                      width: 39.0,
                                                      height: 39,
                                                      decoration:
                                                          new BoxDecoration(
                                                        border: Border.all(
                                                          width: 1.7,
                                                          color: Color.fromRGBO(
                                                              5, 18, 44, 1),
                                                        ),
                                                        shape: BoxShape.circle,
                                                        image:
                                                            new DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: new NetworkImage(
                                                              docs[index][
                                                                  'createdByImg']),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    top: 8,
                                                    bottom: 8,
                                                    right: 12),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        who.split(" ")[0] +
                                                            ' ' +
                                                            docs[index]
                                                                ['txnType'] +
                                                            ' "' +
                                                            docs[index][
                                                                'description'] +
                                                            '".',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                    ),
                                                    if (docs[index]
                                                                ['txnType'] ==
                                                            'added' ||
                                                        docs[index]
                                                                ['txnType'] ==
                                                            'edited')
                                                      txt,
                                                    Text(
                                                        'on ' +
                                                            DateFormat.yMMMd()
                                                                .format((docs[index]
                                                                            [
                                                                            'txnDate']
                                                                        as Timestamp)
                                                                    .toDate()) +
                                                            (isGroup
                                                                ? " in " +
                                                                    docs[index][
                                                                        'groupName']
                                                                : ''),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: docs.length,
                                ),
                              );
                      }),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
