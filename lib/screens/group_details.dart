import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:simplify/helpers/dummy.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:simplify/helpers/snack.dart';

final FirebaseFunctions functions = FirebaseFunctions.instance;
final FirebaseFirestore db = FirebaseFirestore.instance;

class GroupDetails extends StatelessWidget {
  GroupDetails(
      {required this.group, required this.uid, required this.completeData});
  final Map<String, dynamic> group;
  final String uid;
  final Map<String, dynamic> completeData;

  String _getText(DocumentSnapshot group) {
    String who = group['createdBy'] == uid ? 'you' : group['createdByName'];
    return 'created by ' +
        who +
        " on " +
        DateFormat.yMMMd().format((group['createdAt'] as Timestamp).toDate());
  }

  Future<void> _addToGroup(String user, context) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('memberEdit');
      final HttpsCallableResult<dynamic> result =
          await callable({'member': user, 'group': group['gid'], 'opr': 1});
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => GroupDetails(
                    completeData: completeData,
                    uid: uid,
                    group: group,
                  )));
      showSnack(context, 'Friend Added', false);
    } on FirebaseFunctionsException catch (e) {
      Navigator.of(context).pop();
      showSnack(context, e.message ?? '', true);
    } catch (e) {
      Navigator.of(context).pop();
      showSnack(context, "Something went wrong. Try after sometime", true);
    }
  }

  Future<void> deleteGroup(context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete ' + group['name'],
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
                      FirebaseFunctions.instance.httpsCallable('deleteGroup');
                  final HttpsCallableResult<dynamic> result =
                      await callable({'group': group['gid']});
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                  showSnack(context, group['name'] + ' deleted', false);
                } on FirebaseFunctionsException catch (e) {
                  Navigator.of(context).pop();
                  showSnack(context, e.message ?? '', true);
                } catch (e) {
                  Navigator.of(context).pop();
                  showSnack(context, "Something went wrong. Try after sometime",
                      true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> leaveGroup(context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Leave ' + group['name'],
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
                      FirebaseFunctions.instance.httpsCallable('memberEdit');
                  final HttpsCallableResult<dynamic> result = await callable(
                      {'member': uid, 'group': group['gid'], 'opr': 0});
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                  showSnack(context, 'Left ' + group['name'], false);
                } on FirebaseFunctionsException catch (e) {
                  Navigator.of(context).pop();
                  print(e);
                  showSnack(context, e.message ?? '', true);
                } catch (e) {
                  Navigator.of(context).pop();
                  print(e);
                  showSnack(context, "Something went wrong. Try after sometime",
                      true);
                }
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
      future: db.collection('groups').doc(group['gid']).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong" + snapshot.error.toString(),
              style: TextStyle(color: Colors.black, fontSize: 12));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Dummy();
        }

        DocumentSnapshot details = snapshot.data!;

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
                              margin: const EdgeInsets.only(right: 20),
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
                                    group["name"],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(fontSize: 24),
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    "${completeData['currencyCode']} " +
                                        group["value"].toStringAsFixed(1),
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
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Image.asset(
                                'assets/images/' + group['img'] + '.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Expanded(child)
                        ],
                      ),
                      Text(_getText(details),
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              height: 1.5)),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              barrierColor: Colors.black26,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25)),
                              ),
                              context: context,
                              builder: (context) {
                                List<Map<String, dynamic>> toBeAdded = [];
                                List<String> memb = (details['users'] as List)
                                    .map((e) => e['uid'] as String)
                                    .toList();
                                print(memb);
                                (completeData['friends'] as List)
                                    .forEach((element) {
                                  if (!memb.contains(element['uid']))
                                    toBeAdded.add(element);
                                });
                                List<Widget> toBeAddedWidget = toBeAdded
                                    .map((e) => GestureDetector(
                                          onTap: () {
                                            _addToGroup(e['uid'], context);
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: GroupUser(
                                                  user: e,
                                                  color: 1,
                                                  key: ValueKey(e['uid']),
                                                ),
                                              ),
                                              Icon(
                                                Icons.add_box,
                                                color: Colors.black87,
                                                size: 42,
                                              )
                                            ],
                                          ),
                                        ))
                                    .toList();
                                return Container(
                                  // alignment: Alignment.center,
                                  padding: const EdgeInsets.only(
                                      right: 35, left: 35, top: 25),
                                  // height: 295,
                                  constraints: BoxConstraints(maxHeight: 355),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 10),
                                              height: 4.0,
                                              color: Colors.grey[500],
                                              width: 55,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        ...toBeAddedWidget,
                                        // SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 15),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle,
                                color: Colors.green,
                              ),
                              Text(
                                " Add Friend",
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 22,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          leaveGroup(context);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 15),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.blue[400],
                              ),
                              Text(
                                " Leave Group",
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 22,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          deleteGroup(context);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 15),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel,
                                color: Colors.red[400],
                              ),
                              Text(
                                " Delete Group",
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 22,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 25),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        color: Color.fromRGBO(5, 18, 44, 0.98),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: (details['users'] as List)
                              .map((e) => GroupUser(
                                  user: e, color: 0, key: ValueKey(e['uid'])
                                  // group: group,
                                  ))
                              .toList(),
                        ),
                      )),
                )
              ]),
        );
      },
    );
  }
}

class GroupUser extends StatelessWidget {
  const GroupUser(
      {required Key key,
      // required this.group,
      required this.user,
      required this.color})
      : super(key: key);

  // final Map<String, dynamic> group;
  final Map<String, dynamic> user;
  final int color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.only(right: 20, top: 9, bottom: 9),
            height: 70,
            width: 70,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
                color: Colors.green.shade500,
              ),
              image: new DecorationImage(
                fit: BoxFit.contain,
                image: new NetworkImage(user['img']!),
              ),
            ),
            // width: 78,
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: color == 0
                    ? Text(user['name']!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 20))
                    : Text(user['name']!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 20, color: Colors.black87)),
              ),
              if (user['email'] != null && user['email'] != "")
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(user['email'],
                      style: color == 0
                          ? Theme.of(context).textTheme.bodyText2
                          : Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.black54)),
                ),
              if (user['phone'] != null && user['phone'] != "")
                Text(user['phone'],
                    style: color == 0
                        ? Theme.of(context).textTheme.bodyText2
                        : Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: Colors.black54))
            ],
          ),
        ),
      ],
    );
  }
}
