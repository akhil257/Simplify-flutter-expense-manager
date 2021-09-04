import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:simplify/helpers/firehelpers.dart';
import 'package:simplify/helpers/snack.dart';
import 'package:simplify/screens/add_settle.dart';
import 'package:simplify/screens/new_transaction.dart';
import 'package:simplify/screens/view_bill.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class FriendsHistory extends StatelessWidget {
  FriendsHistory(this.data, this.friend, this.uid, this.name, this.img);
  final Map<String, dynamic> friend;
  final Map<String, dynamic> data;
  final String uid;
  final String name;
  final String img;
  Future<QuerySnapshot> offlineq() async {
    try {
      await db.disableNetwork();
      QuerySnapshot i = await db
          .collection('transactions')
          .where('users', arrayContains: friend['uid'])
          .orderBy('createdAt', descending: true)
          .get();
      // i=i[0];
      await db.enableNetwork();
      return i;
    } catch (e) {
      await db.enableNetwork();
      throw Exception('Fetch history failed');
    }
  }

  Future<void> _showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Remove ' + friend['name'],
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Colors.black, fontSize: 24),
          ),
          content: Text('Do you want to continue?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                try {
                  HttpsCallable callable =
                      FirebaseFunctions.instance.httpsCallable('removeFriend');
                  final HttpsCallableResult<dynamic> result = await callable({
                    'toRemove': [uid, friend['uid']]
                  });
                  Navigator.of(context).pop();
                  print(result);
                  showSnack(context, friend['name'] + ' removed', false);
                } catch (e) {}
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: offlineq(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var snapDocs = snapshot.data!.docs;
          List<QueryDocumentSnapshot> docs = [];
          if (snapDocs.length > 0) {
            snapDocs.forEach((doc) {
              if ((doc['users'] as List).contains(uid)) {
                docs.add(doc);
              }
            });
          }

          return Scaffold(
              backgroundColor: Color.fromRGBO(5, 18, 44, 1),
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
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
                                  //  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.chevron_left,
                                      color: Colors.white, size: 36),
                                )
                              ],
                            ),
                          )),
                ],
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                toolbarHeight: 80,
                titleSpacing: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          margin: const EdgeInsets.only(right: 20, left: 20),
                          decoration: new BoxDecoration(
                            border: Border.all(
                              width: 1.2,
                              color: friend['value'] < 0
                                  ? Colors.red
                                  : Colors.green.shade500,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: new NetworkImage(friend['img']),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend['name'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontSize: 22,
                                  ),
                            ),
                            Text(
                              "${data['currencyCode']} " +
                                  friend['value'].abs().toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      child: IconButton(
                    onPressed: () {
                      _showMyDialog(context);
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 34,
                    ),
                  )),
                  Container(
                    width: 180,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => AddSettle(
                                    mode: 'Settle',
                                    uid: uid,
                                    data: [friend],
                                    img: img,
                                    completeData:data,
                                    name: name)));
                      },
                      child: Text(
                        'Settle',
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
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
                                builder: (BuildContext context) => AddSettle(
                                    mode: 'Add',
                                    uid: uid,
                                    data: [friend],
                                    img: img,
                                    completeData: data,
                                    name: name)));
                      },
                      iconSize: 50,
                      splashColor: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Txn(docs: docs, uid: uid, friend: friend, data: data),
                  SizedBox(height: 80)
                ],
              ));
        });
  }
}

class Txn extends StatelessWidget {
  const Txn({
    Key? key,
    required this.docs,
    required this.uid,
    required this.friend,
    required this.data,
  }) : super(key: key);

  final List<QueryDocumentSnapshot> docs;
  final String uid;
  final Map<String, dynamic> friend;
  final Map<String, dynamic> data;

  Future<void> _deleteTxn(
      QueryDocumentSnapshot txn, String uid, context) async {
    bool flag = await FireHelpers().delete(txn, uid);
    if (flag) {
      Navigator.of(context).pop();
      showSnack(context, 'Bill Deleted', false);
    } else
      showSnack(context, 'Something went wrong', true);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: docs.length,
        reverse: true,
        itemBuilder: (context, index) {
          // var docs = snapshot.data!.docs;
          var isOwner = uid == docs[index]['createdBy'];
          var who = isOwner ? 'You' : docs[index]['createdByName'];
          var split = (docs[index]['split'] as List)
              .firstWhere((element) => element['uid'] == uid);
          var totAmt = split['total'];
          var friendAmt = 0.0;
          try {
            friendAmt = (split['breakage'] as List).firstWhere(
                (element) => element['uid'] == friend['uid'])['value'];
          } catch (e) {}
          Widget txt;
          if (friendAmt > 0) {
            txt = Text('You get ${data['currencyCode']} ${friendAmt.toString()}',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.green[500],
                    decoration:
                        docs[index]['isDeleted'] || docs[index]['isEdited']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                    fontWeight: FontWeight.w400));
          } else if (friendAmt < 0) {
            txt = Text(
              'You owe ${data['currencyCode']} ' + friendAmt.abs().toString(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Colors.red[400],
                  decoration:
                      docs[index]['isDeleted'] || docs[index]['isEdited']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  fontWeight: FontWeight.w400),
            );
          } else {
            txt = Text(
              'Not part of this',
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Colors.white60,
                  decoration:
                      docs[index]['isDeleted'] || docs[index]['isEdited']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  fontWeight: FontWeight.w400),
            );
          }
          return Row(
            mainAxisAlignment:
                isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => ViewBill(
                                      data: data,
                                      bill: docs[index],
                                      uid: uid)));
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, left: 20, right: 10),
                          margin: const EdgeInsets.only(
                              bottom: 5, left: 12, right: 12),
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft:
                                  !isOwner ? Radius.zero : Radius.circular(20),
                              bottomRight:
                                  isOwner ? Radius.zero : Radius.circular(20),
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            // color: Colors.white24,
                            gradient: LinearGradient(
                                colors: [Colors.white12, Colors.white30],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            border: Border.all(
                              width: 0.4,
                              color: Colors.white12,
                            ),
                          ),
                          width: 265,
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                who +
                                    ' ' +
                                    docs[index]['txnType'] +
                                    ' ' +
                                    docs[index]['description'],
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              if (docs[index]['txnType'] != 'deleted')
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: txt,
                                      alignment: Alignment.centerLeft,
                                    )),
                                    !docs[index]['isDeleted'] &&
                                            !docs[index]['isEdited']
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                height: 25,
                                                width: 35,
                                                child: IconButton(
                                                  padding: EdgeInsets.all(0),
                                                  onPressed: () {
                                                    _deleteTxn(docs[index], uid,
                                                        context);
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.blueGrey[200],
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 25,
                                                width: 40,
                                                child: IconButton(
                                                  padding: EdgeInsets.all(0),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                NewTransaction(
                                                                  data: data,
                                                                  uid: uid,
                                                                  isEdit: true,
                                                                  bill: docs[
                                                                      index],
                                                                  groupAdd:
                                                                      false,
                                                                )));
                                                  },
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.blueGrey[200],
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : docs[index]['isDeleted']
                                            ? Text('Deleted',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2)
                                            : Text('Edited',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2),
                                  ],
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 260,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: isOwner
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isOwner)
                          Text(
                              'on ' +
                                  DateFormat.yMMMd().format(
                                      (docs[index]['txnDate'] as Timestamp)
                                          .toDate()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(fontSize: 13)),
                        Container(
                          width: 22,
                          height: 22,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image:
                                  new NetworkImage(docs[index]['createdByImg']),
                            ),
                          ),
                        ),
                        if (!isOwner)
                          Text(
                              'on ' +
                                  DateFormat.yMMMd().format(
                                      (docs[index]['txnDate'] as Timestamp)
                                          .toDate()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
