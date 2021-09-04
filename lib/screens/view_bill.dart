import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:simplify/helpers/const_widgets.dart';
import 'package:simplify/helpers/dummy.dart';
import 'package:simplify/helpers/firehelpers.dart';
import 'package:simplify/helpers/snack.dart';

import 'new_transaction.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class ViewBill extends StatelessWidget {
  ViewBill({
    required this.data,
    required this.uid,
    required this.bill,
  });
  final String uid;
  final QueryDocumentSnapshot bill;
  final Map<String, dynamic> data;

  Future<Map<String, List<DocumentSnapshot>>> getHist() async {
    QuerySnapshot i;
    List<DocumentSnapshot> docs = [];
    try {
      if (bill["isParent"]) {
        i = await db
            .collection('transactions')
            .where('parent', isEqualTo: bill.id)
            .orderBy('createdAt', descending: true)
            .get();
        docs = i.docs;
        docs.add(bill);
      } else {
        i = await db
            .collection('transactions')
            .where('parent', isEqualTo: bill["parent"])
            .orderBy('createdAt', descending: true)
            .get();
        i.docs.forEach((element) {
          docs.add(element);
        });
        DocumentSnapshot p =
            await db.collection('transactions').doc(bill['parent']).get();
        docs.add(p);
      }
      print(docs);
      List<DocumentSnapshot> g = [];
      if (bill['isGroup']) {
        DocumentSnapshot group =
            await db.collection('groups').doc(bill['groupId']).get();
        g.add(group);
      }
      return {'docs': docs, 'group': g};
      // i=i[0];

    } catch (e) {
      print(e);
      print(e.toString());
      throw Exception('Fetch history failed');
    }
  }

  Future<void> _deleteTxn(
      QueryDocumentSnapshot txn, String uid, context) async {
    bool flag = await FireHelpers().delete(txn, uid);
    if (flag) {
      Navigator.of(context).pop();
      showSnack(context, 'Bill deleted', false);
    } else
      showSnack(context, 'Something went wrong', true);
  }

  String _getText(DocumentSnapshot bill) {
    String who = bill['createdBy'] == uid ? 'you' : bill['createdByName'];
    return bill['txnType'] +
        ' by ' +
        who +
        " on " +
        DateFormat.yMMMd().format((bill['txnDate'] as Timestamp).toDate());
  }

  @override
  Widget build(BuildContext context) {
    // String who = bill['createdBy'] == uid ? 'You' : bill['createdByName'];
    List<dynamic> split = bill['split'];

    return FutureBuilder(
      future: getHist(),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, List<DocumentSnapshot>>> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong" + snapshot.error.toString(),
              style: TextStyle(color: Colors.black, fontSize: 12));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Dummy();
        }

        List<DocumentSnapshot> docs = snapshot.data!['docs']!;
        bool isLatest = docs[0].id == bill.id;
        bool isDeleted = docs[0]["txnType"] == 'deleted';
        List<String> friends =
            (data['friends'] as List).map((e) => e['uid'] as String).toList();
        print(friends);
        bool allFriends = true;
        for (String user in bill['concernedUsers'] as List) {
          if (!friends.contains(user) && user != uid) {
            print(user);
            allFriends = false;
            break;
          }
        }
        print(">>>>>>>>>>>");
        print(allFriends);
        bool allGroups = true;
        bool isGroup = true;
        if (bill['isGroup']) {
          List<dynamic> groupUsers = snapshot.data!['group']![0]['users']!
              .map((e) => e['uid'].toString())
              .toList();
          print(groupUsers);
          for (String user in bill['concernedUsers'] as List) {
            if (!groupUsers.contains(user)) {
              allGroups = false;
              break;
            }
          }
          isGroup = !snapshot.data!['group']![0]['isDeleted'];
        }
        print(">>>>>>>>>>>");
        print(allGroups);
        print(isGroup);
        bool canProcess =
            isLatest && !isDeleted && allFriends && allGroups && isGroup;
        return Scaffold(
          appBar: AppBar(
            actions: [
              Builder(
                  builder: (context) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black45, width: 1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.chevron_left,
                                  color: Colors.black54, size: 36),
                            )
                          ],
                        ),
                      )),
            ],
            systemOverlayStyle:
                Theme.of(context).appBarTheme.systemOverlayStyle,
            backwardsCompatibility:
                Theme.of(context).appBarTheme.backwardsCompatibility!,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ' SIMPLIFY.',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: Theme.of(context).appBarTheme.elevation,
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 45,
                width: 150,
                margin: const EdgeInsets.only(left: 25),
                child: ElevatedButton(
                  onPressed: canProcess
                      ? () {
                          _deleteTxn(bill, uid, context);
                        }
                      : () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        color: canProcess ? Colors.white : Colors.black38,
                      ),
                      Text('Delete',
                          style: TextStyle(
                            color: canProcess ? Colors.white : Colors.black38,
                          )),
                    ],
                  ),
                ),
              ),
              Container(
                height: 45,
                width: 150,
                margin: EdgeInsets.only(left: 25),
                child: ElevatedButton(
                  onPressed: canProcess
                      ? () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      NewTransaction(
                                        data: data,
                                        uid: uid,
                                        isEdit: true,
                                        bill: bill,
                                        groupAdd: false,
                                      )));
                        }
                      : () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        color: canProcess ? Colors.white : Colors.black38,
                      ),
                      Text('Edit',
                          style: TextStyle(
                            color: canProcess ? Colors.white : Colors.black38,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  child: Text(
                                    bill["description"],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(fontSize: 24),
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    "${data['currencyCode']} " + bill["amount"],
                                    style: TextStyle(
                                      fontSize: 58,
                                      color: Color.fromRGBO(5, 18, 44, 0.9),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(5),
                              // width: 52,
                              height: 72,
                              decoration: BoxDecoration(
                                  // color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8)),
                              child: bill['icon'] == null || bill['icon'] == ''
                                  ? Image.asset(
                                      'assets/images/' +
                                          bill['imageUrl'] +
                                          '.png',
                                      fit: BoxFit.contain,
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        Pic(bill['icon'])));
                                        // showModalBottomSheet(
                                        //     barrierColor: Colors.black26,
                                        //     backgroundColor: Colors.white,
                                        //     shape: RoundedRectangleBorder(
                                        //       borderRadius:
                                        //           BorderRadius.vertical(
                                        //               top: Radius.circular(25)),
                                        //     ),
                                        //     context: context,
                                        //     builder: (context) => Container(
                                        //       width: double.infinity,
                                        //           alignment: Alignment.center,
                                        //           padding: const EdgeInsets
                                        //                   .symmetric(
                                        //               horizontal: 35,
                                        //               vertical: 25),
                                        //           height: 595,
                                        //           child: InteractiveViewer(

                                        //               child: Image.network(
                                        //                   bill['icon'],
                                        //                   fit: BoxFit.cover,width: double.infinity ,)),
                                        //         ));
                                        // // child:
                                      },
                                      child: Image.network(bill['icon'])),
                            ),
                          ),
                          // Expanded(child)
                        ],
                      ),
                      if (bill['isGroup'])
                        Text(
                          "in " + bill['groupName'],
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(fontSize: 16),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: docs
                            .map((e) => Text(_getText(e),
                                style: TextStyle(
                                    color: e.id == bill.id
                                        ? Colors.black87
                                        : Colors.black54,
                                    fontSize: e.id == bill.id ? 15 : 14,
                                    fontFamily: 'Inter',
                                    height: 1.5)))
                            .toList(),
                      ),
                      if (!isLatest)
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ViewBill(
                                              data: data,
                                              bill: docs[0]
                                                  as QueryDocumentSnapshot,
                                              uid: uid)));
                            },
                            child: ScreenMessage(
                                msg:
                                    "This bill was edited. Tap to view latest edit",
                                theme: 1)),
                      if (isDeleted)
                        ScreenMessage(
                          msg: "This expense is deleted",
                          theme: 0,
                        ),
                      if (!allFriends)
                        ScreenMessage(
                          msg: "Some users are not in friends list",
                          theme: 0,
                        ),
                      if (bill['isGroup'] && !allGroups)
                        ScreenMessage(
                          msg: "Some users are not in this group anymore",
                          theme: 0,
                        ),
                      if (bill['isGroup'] && !isGroup)
                        ScreenMessage(
                          msg: "This group was deleted",
                          theme: 0,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 25),
                      padding:
                          EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        color: Color.fromRGBO(5, 18, 44, 1),
                      ),
                      child: ListView.builder(
                          itemCount: bill['split'].length,
                          itemBuilder: (context, index) {
                            return Split(user: bill['split'][index],data: data,);
                          })),
                ),
              ]),
        );
      },
    );
  }
}

class Split extends StatelessWidget {
  const Split({Key? key, required this.user, required this.data}) : super(key: key);

  final Map<String, dynamic> user;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.only(right: 15, top: 9, bottom: 9),
            decoration: new BoxDecoration(
              border: Border.all(
                width: 1.5,
                color: user['total'] < 0 ? Colors.red : Colors.green.shade500,
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 70.0,
              height: 70,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: new NetworkImage(user['img']),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(user['name']!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 20)),
              ),
              Text(
                  'paid ${data['currencyCode']} ${user['paid'].toStringAsFixed(1)} and owes ${data['currencyCode']} ${user['owes'].toStringAsFixed(1)}'),
            ],
          ),
        ),
      ],
    );
  }
}

class ScreenMessage extends StatelessWidget {
  const ScreenMessage({
    Key? key,
    required this.msg,
    required this.theme,
  }) : super(key: key);

  final String msg;
  final int theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: theme == 1 ? Colors.blue[100] : Colors.red[50],
          borderRadius: BorderRadius.circular(5)),
      child: Text(
        "\u25CB " + msg,
        style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: theme == 1 ? Colors.blue : Colors.red,
            fontWeight: FontWeight.w300),
      ),
    );
  }
}
