import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:simplify/helpers/constants.dart';
import 'package:simplify/helpers/drawer.dart';
import 'package:simplify/helpers/helperfunc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplify/helpers/snack.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class NewTransaction extends StatefulWidget {
  NewTransaction(
      {required this.data,
      required this.uid,
      this.bill,
      required this.isEdit,
      required this.groupAdd,
      this.groupSel});
  final String uid;
  final QueryDocumentSnapshot? bill;
  final Map<String, dynamic> data;
  final Map<String, dynamic>? groupSel;
  final bool isEdit;
  final bool groupAdd;
  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();

  List<dynamic> recentList = [];
  List<dynamic> list = [];
  List<dynamic> concernedList = [];
  List<File> fileList = [];
  bool isEqual = true;
  bool isGroup = false;
  String groupId = '';
  String groupName = '';
  String groupImg = '';
  double flexHeight = 420;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // db.enableNetwork();
    list = widget.data['friends'] + widget.data['groups'];
    recentList = widget.data['friends'] + widget.data['groups'];

    if (widget.isEdit && widget.bill != null) {
      var bill = widget.bill!;
      _descriptionController.text = bill['description'];
      _amountController.text = bill['amount'].toString();
      selectedDate = (bill['txnDate'] as Timestamp).toDate();
      if (bill['isGroup']) {
        isGroup = true;
        var group = (widget.data['groups'] as List)
            .firstWhere((e) => e['gid'] == bill['groupId']);
        groupName = group['name'];
        groupImg = group['img'];
        groupId = bill['groupId'];
      }
      List<dynamic> split = bill['split'];
      split.forEach((elm) {
        concernedList.add({
          'uid': elm['uid'],
          'img': elm['img'],
          'name': elm['name'],
          'didPaid': (elm['paid'] ?? 0) > 0,
          'didOwes': (elm['owes'] ?? 0) > 0,
          'paidController':
              TextEditingController(text: (elm['paid'] ?? '').toString()),
          'owedController':
              TextEditingController(text: (elm['owes'] ?? '').toString()),
          'totalController':
              TextEditingController(text: (elm['total'] ?? '').toString()),
        });
        recentList.removeWhere((element) => element['uid'] == elm['uid']);
      });
    } else {
      if (widget.groupAdd) {
        isGroup = true;
        addToList(0, widget.groupSel);
      } else {
        concernedList.add({
          'uid': widget.uid,
          'img': widget.data['img'],
          'name': widget.data['name'],
          'didPaid': true,
          'didOwes': true,
          'paidController': TextEditingController(),
          'owedController': TextEditingController(),
          'totalController': TextEditingController(),
        });
      }
    }
  }

  void _add() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        var splitted =
            HelperFunctions().split(concernedList, _amountController.text);
        setState(() {
          isLoading = true;
        });
        var imgUrl = '';
        String downloadURL = '';
        String t = DateTime.now().toString();
        if (widget.isEdit) {
          imgUrl = widget.bill!['imageUrl'];
          downloadURL = widget.bill!['icon'];
        } else {
          String desc = _descriptionController.text.split(" ").last;
          imgUrl = 'c1';
          if (food.contains(desc.toLowerCase())) {
            imgUrl = 'c4';
          } else if (drinks.contains(desc.toLowerCase())) {
            imgUrl = 'c7';
          } else if (travel.contains(desc.toLowerCase())) {
            imgUrl = 'c9';
          } else if (fuel.contains(desc.toLowerCase())) {
            imgUrl = 'c10';
          } else if (beverages.contains(desc.toLowerCase())) {
            imgUrl = 'c2';
          } else if (snack.contains(desc.toLowerCase())) {
            imgUrl = 'c5';
          } else if (shopping.contains(desc.toLowerCase())) {
            imgUrl = 'c8';
          } else if (groceries.contains(desc.toLowerCase())) {
            imgUrl = 'c3';
          } else if (rent.contains(desc.toLowerCase())) {
            imgUrl = 'c6';
          }

          if (fileList.length > 0) {
            try {
              await firebase_storage.FirebaseStorage.instance
                  .ref('bills/$t.png')
                  .putFile(fileList[0]);
              downloadURL = await firebase_storage.FirebaseStorage.instance
                  .ref('bills/$t.png')
                  .getDownloadURL();
            } catch (e) {}
          }
        }
        List parentsList = [];
        var users = splitted['users'];
        if (widget.isEdit) {
          parentsList = widget.bill!['parents'];
          parentsList.add(widget.bill!.id);
          users = ((widget.bill!['concernedUsers'] + splitted['users']) as List)
              .toSet()
              .toList();
        }
        try {
          DocumentReference ref = await db.collection('transactions').add(
            {
              'txnType': widget.isEdit ? 'edited' : 'added',
              'amount': _amountController.text,
              'currency': widget.data['currency'],
              'currencyCode':widget.data['currencyCode'],
              'users': users,
              'concernedUsers': splitted['users'],
              'split': splitted['split'],
              'prevSplit': widget.isEdit ? widget.bill!['split'] : null,
              'icon': downloadURL,
              'imageUrl': imgUrl,
              'comment': null,
              'description': _descriptionController.text,
              'txnDate': selectedDate,
              'isEqual': isEqual,
              'isGroup': isGroup,
              'groupId': isGroup ? groupId : null,
              'groupName': isGroup ? groupName : null,
              'isParent': !widget.isEdit,
              'parents': parentsList,
              'prevParent': widget.isEdit ? widget.bill!.id : null,
              'parent': widget.isEdit
                  ? widget.bill!["isParent"]
                      ? widget.bill!.id
                      : widget.bill!["parent"]
                  : null,
              'isProcessed': false,
              'isDeleted': false,
              'isEdited': false,
              'createdBy': widget.uid,
              'createdByName': widget.data['name'],
              'createdByImg': widget.data['img'],
              'createdAt': Timestamp.now(),
            },
          );
          showSnack(context, 'Bill added', false);
          Navigator.popUntil(context, ModalRoute.withName("/"));
        } catch (e) {
          print(e);
          showSnack(context, 'Something went wrong', true);
        }
      } catch (e) {
        print(e);
        showSnack(context, 'Amounts do not match', true);
      }
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate, // Refer step 1
        firstDate: DateTime(2011),
        lastDate: DateTime(2029),
        helpText: 'Select bill date');
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _descriptionController.dispose();
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void addToList(index, data) async {
    if (data['gid'] != null) {
      try {
        DocumentSnapshot i =
            await db.collection('groups').doc(data['gid']).get();
        List users = i.data()!['users'] as List;
        List usersList = [];
        usersList.add({
          'uid': widget.uid,
          'img': widget.data['img'],
          'name': widget.data['name'],
          'didPaid': true,
          'didOwes': true,
          'paidController': TextEditingController(),
          'owedController': TextEditingController(),
          'totalController': TextEditingController(),
        });
        users.forEach((e) {
          if (e['uid'] != widget.uid)
            usersList.add({
              'uid': e['uid'],
              'name': e['name'],
              'img': e['img'],
              'didPaid': false,
              'didOwes': true,
              'paidController': TextEditingController(),
              'owedController': TextEditingController(),
              'totalController': TextEditingController(),
            });
        });

        groupName = data['name'];
        groupImg = data['img'];

        setState(() {
          flexHeight = 320;
          concernedList = usersList.toList();
          isGroup = true;
          groupId = data['gid'];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          content: Text('Not able to fetch group.'),
        ));
      }
    } else {
      data['didPaid'] = false;
      data['didOwes'] = true;
      data['paidController'] = TextEditingController();
      data['owedController'] = TextEditingController();
      data['totalController'] = TextEditingController();
      setState(() {
        recentList.removeAt(index);
        // list.removeWhere((item) => item['uid'] == data['uid']);
        concernedList.add(data);
      });
    }

    if (_amountController.text.length > 0) {
      setAmount();
    }

    if (recentList.length == 0) {
      setState(() {
        flexHeight = 320;
      });
    }
  }

  void removeConcerned(data) {
    setState(() {
      recentList.insert(0, data);
      concernedList.removeWhere((item) => item['uid'] == data['uid']);
      list.insert(0, data);
      flexHeight = 420;
    });
    if (_amountController.text.length > 0) {
      setAmount();
    }
  }

  void paidClick(data) {
    setState(() {
      data['didPaid'] = !data['didPaid'];
    });
    if (_amountController.text.length > 0) {
      setAmount();
    }
  }

  void owedClick(data) {
    setState(() {
      data['didOwes'] = !data['didOwes'];
    });
    if (_amountController.text.length > 0) {
      setAmount();
    }
  }

  void _removeGroup() {
    setState(() {
      flexHeight = 420;

      isGroup = false;
      list = widget.data['friends'] + widget.data['groups'];
      recentList = widget.data['friends'] + widget.data['groups'];
      concernedList = [
        {
          'uid': widget.uid,
          'img': widget.data['img'],
          'name': widget.data['name'],
          'didPaid': true,
          'didOwes': true,
          'paidController': TextEditingController(),
          'owedController': TextEditingController(),
          'totalController': TextEditingController(),
        }
      ];
    });
  }

  void setAmount() {
    FocusScope.of(context).unfocus();
    int paidCount = 0;
    int owedCount = 0;
    if (isEqual && _amountController.text != '') {
      // setState(() {
      var amt = int.parse(_amountController.text);

      concernedList.forEach((elm) {
        if (elm['didPaid']) {
          paidCount++;
        }
        if (elm['didOwes']) {
          owedCount++;
        }
      });
      concernedList.forEach((elm) {
        TextEditingController ct = elm['owedController'];
        if (elm['didOwes']) {
          ct.text = (amt / owedCount).toStringAsFixed(1);
        } else {
          ct.text = '0.0';
        }
      });

      concernedList.forEach((elm) {
        TextEditingController ct = elm['paidController'];
        if (elm['didPaid']) {
          ct.text = (amt / paidCount).toStringAsFixed(1);
        } else {
          ct.text = '0.0';
        }
      });

      concernedList.forEach((elm) {
        String paidString =
            (elm['paidController'] as TextEditingController).text;
        double paid = double.parse(paidString == '' ? '0' : paidString);
        String owedString =
            (elm['owedController'] as TextEditingController).text;
        double owed = double.parse(owedString == '' ? '0' : owedString);
        double total = paid - owed;
        (elm['totalController'] as TextEditingController).text =
            total.toStringAsFixed(1);
      });
    }
  }

  File? pickedFile = null;

  bool isSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 250,
            margin: const EdgeInsets.only(left: 25),
            child: ElevatedButton(
              onPressed: isLoading ? () {} : _add,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? Container(
                          width: 22,
                          height: 22,
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            strokeWidth: 2,
                          ))
                      : Icon(
                          Icons.add,
                          size: 34,
                        ),
                  Text(
                    widget.isEdit ? 'Edit Bill' : ' Add Bill',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: CustomDrawer(
          data: widget.data,
          uid: widget.uid,
          isHome: false,
        ),
      ),
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
                                      'Hi ' + widget.data['name'].split(" ")[0],
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 22, left: 12),
                                  width: 37.0,
                                  height: 37,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      image:
                                          new NetworkImage(widget.data['img']),
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
                // This is the title in the app bar.
                pinned: true,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                elevation: Theme.of(context).appBarTheme.elevation,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                collapsedHeight: 70,
                expandedHeight: flexHeight,
                flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 70),
                    padding:
                        const EdgeInsets.only(top: 26, left: 15, right: 10),
                    child: SingleChildScrollView(
                        child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FirstRow(_descriptionController, fileList),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(color: Colors.black87),
                                  onEditingComplete: setAmount,
                                  keyboardType: TextInputType.number,
                                  controller: _amountController,
                                  decoration: InputDecoration(
                                    // contentPadding: EdgeInsets.symmetric(horizontal: 50),
                                    prefixIcon: Container(
                                      width: 20,
                                      margin: EdgeInsets.only(
                                          left: 18, top: 10, right: 0),
                                      child: Text(
                                        "${widget.data['currencyCode']}    ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                color: Colors.black87,
                                                fontSize: 24),
                                      ),
                                    ),
                                    isDense: true,
                                    labelText: "Amount",
                                    errorStyle:
                                        TextStyle(fontSize: 0, height: 0),
                                    focusedErrorBorder: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(8.0),
                                      borderSide:
                                          new BorderSide(color: Colors.red),
                                    ),
                                    labelStyle: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(color: Colors.black54),
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(8.0),
                                      borderSide: new BorderSide(),
                                    ),
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10, right: 3),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black38),
                                    borderRadius: BorderRadius.circular(15)),
                                padding: EdgeInsets.symmetric(vertical: 7),
                                width: 53,
                                child: FittedBox(
                                  child: TextButton(
                                    child: Text(
                                      DateFormat.Md().format(selectedDate),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                              color: Colors.black87,
                                              fontSize: 18),
                                    ),
                                    onPressed: () => _selectDate(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 9,
                                child: isGroup
                                    ? GestureDetector(
                                        onTap: _removeGroup,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 0),
                                          margin: EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              border: Border.all(
                                                  color: Colors.grey,
                                                  width: 0.4)),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 15),
                                                  height: 44,
                                                  decoration: new BoxDecoration(
                                                      image:
                                                          new DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: new AssetImage(
                                                            'assets/images/' +
                                                                groupImg +
                                                                '.png'),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  width: 44,
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    '' + groupName,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1!
                                                        .copyWith(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.black87),
                                                  )),
                                              Expanded(
                                                flex: 2,
                                                child: Icon(
                                                  Icons.cancel,
                                                  color: Colors.grey,
                                                  size: 28,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : TextField(
                                        controller: _searchController,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                color: Colors.black87,
                                                fontSize: 16),
                                        onChanged: (String query) {
                                          setState(() {
                                            recentList = list
                                                .where((elem) => elem['name']
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(
                                                        query.toLowerCase()))
                                                .toList();
                                          });
                                        },
                                        cursorColor: Colors.black26,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(left: 20),
                                          filled: true,
                                          fillColor: Colors.black12,
                                          suffixIcon: Icon(Icons.search),
                                          isDense: true,
                                          focusColor: Colors.black54,
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          labelText: "Search",
                                          labelStyle: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(
                                                  color: Colors.black54,
                                                  fontSize: 16),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(26.0),
                                            borderSide: new BorderSide(
                                                style: BorderStyle.none,
                                                width: 0),
                                          ),
                                        ),
                                      ),
                              ),
                              Container(
                                width: 98,
                                margin: EdgeInsets.only(left: 15),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    // primary: Colors.green.shade600,
                                    elevation: 4,
                                    padding: EdgeInsets.only(
                                        top: 12, bottom: 12, left: 17),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Equal ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isEqual
                                              ? Colors.white
                                              : Colors.black38,
                                        ),
                                      ),
                                      Icon(
                                        isEqual
                                            ? Icons.lock_outline
                                            : Icons.lock_open,
                                        size: 18,
                                        color: isEqual
                                            ? Colors.white
                                            : Colors.black38,
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isEqual = !isEqual;
                                    });
                                    setAmount();
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (!isGroup)
                            Container(
                              margin: EdgeInsets.only(top: 12),
                              height: 95,
                              child: ListView.builder(
                                itemCount: recentList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () =>
                                        addToList(index, recentList[index]),
                                    child: Container(
                                      margin: EdgeInsets.only(right: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 68,
                                            decoration: new BoxDecoration(
                                              color: Colors.white,
                                              shape: recentList[index]['gid'] ==
                                                      null
                                                  ? BoxShape.circle
                                                  : BoxShape.rectangle,
                                              borderRadius: recentList[index]
                                                          ['gid'] !=
                                                      null
                                                  ? BorderRadius.circular(15)
                                                  : null,
                                              image: recentList[index]['gid'] ==
                                                      null
                                                  ? new DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: new NetworkImage(
                                                          recentList[index]
                                                              ['img']),
                                                    )
                                                  : new DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: new AssetImage(
                                                          'assets/images/' +
                                                              recentList[index]
                                                                  ['img'] +
                                                              '.png'),
                                                    ),
                                            ),
                                            width: 68,
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            recentList[index]['name']
                                                .split(" ")[0],
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6!
                                                .copyWith(
                                                    color: Colors.black
                                                        .withOpacity(0.75),
                                                    fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                        ],
                      ),
                    ))),
                forceElevated: innerBoxIsScrolled,
                bottom: PreferredSize(
                    preferredSize: const Size(double.infinity, 20),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(5, 18, 44, 1),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(300),
                            topRight: Radius.circular(300)),
                      ),
                      height: 30,
                    )),
              ),
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(5, 18, 44, 1),
          ),
          child: Builder(builder: (BuildContext context) {
            return CustomScrollView(slivers: <Widget>[
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 14,
                ),
                sliver: SliverFixedExtentList(
                  itemExtent: 108.0,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      var data = concernedList[index];
                      return Container(
                        height: 102,
                        margin: EdgeInsets.only(bottom: 12),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                        decoration: BoxDecoration(),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.uid != data['uid'])
                                    removeConcerned(data);
                                },
                                child:
                                    Stack(clipBehavior: Clip.none, children: [
                                  Container(
                                    height: 64,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: new NetworkImage(data['img']),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      right: -3,
                                      top: -4,
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        child: Icon(
                                          Icons.cancel_rounded,
                                          color: widget.uid == data['uid']
                                              ? Colors.grey
                                              : Colors.amber,
                                        ),
                                      ))
                                ]),
                              ),
                            ),
                            Expanded(
                              flex: 14,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 18, right: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  data['name'].split(" ")[0] +
                                                      " ",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .copyWith(fontSize: 19)),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 8,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    paidClick(data);
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 3,
                                                            horizontal: 10),
                                                    decoration: BoxDecoration(
                                                        color: data['didPaid']
                                                            ? Colors.green[500]
                                                            : Colors
                                                                .transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                          color: Colors
                                                              .green[500]!,
                                                          width: 1,
                                                        )),
                                                    child: Text("Paid",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6!
                                                            .copyWith(
                                                                color: data[
                                                                        'didPaid']
                                                                    ? Colors
                                                                        .white
                                                                    : Colors.green[
                                                                        500],
                                                                fontSize: 17)),
                                                  ),
                                                ),
                                                Container(
                                                  width: 95,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white12,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      border: Border.all(
                                                          color: Colors.green,
                                                          width: 0.6)),
                                                  child: TextFormField(
                                                    enabled: data['didPaid'],
                                                    onTap: null,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    cursorColor:
                                                        Colors.green[500],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6!
                                                        .copyWith(
                                                            color: Colors.white,
                                                            fontSize: 18),
                                                    textAlign: TextAlign.end,
                                                    controller:
                                                        data['paidController'],
                                                    decoration:
                                                        new InputDecoration(
                                                      prefixText: "${widget.data['currencyCode']} ",
                                                      prefixStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .headline6!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 2.5,
                                                              horizontal: 6),
                                                      isCollapsed: true,
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            width: 55,
                                            child: TextFormField(
                                              readOnly: true,
                                              enabled: false,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2,
                                              textAlign: TextAlign.start,
                                              controller:
                                                  data['totalController'],
                                              decoration: new InputDecoration(
                                                prefixText: "${widget.data['currencyCode']} ",
                                                prefixStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 2.5,
                                                        horizontal: 6),
                                                isCollapsed: true,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 8,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  owedClick(data);
                                                },
                                                child: Container(
                                                  // width: double.minPositive,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 4.5),
                                                  decoration: BoxDecoration(
                                                      color: data['didOwes']
                                                          ? Colors.red[800]
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      border: Border.all(
                                                        color: Colors.red,
                                                        width: 1,
                                                      )),
                                                  child: Text(
                                                    "Owes",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6!
                                                        .copyWith(
                                                            color: data[
                                                                    'didOwes']
                                                                ? Colors.white
                                                                : Colors.red,
                                                            fontSize: 17),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 95,
                                                decoration: BoxDecoration(
                                                    color: Colors.white12,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                        color: Colors.red[300]!,
                                                        width: 0.6)),
                                                child: TextFormField(
                                                  enabled: data['didOwes'],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  cursorColor: Colors.red,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6!
                                                      .copyWith(
                                                          color: Colors.white,
                                                          fontSize: 18),
                                                  textAlign: TextAlign.end,
                                                  controller:
                                                      data['owedController'],
                                                  decoration:
                                                      new InputDecoration(
                                                    border: InputBorder.none,
                                                    prefixText: "${widget.data['currencyCode']} ",
                                                    prefixStyle: Theme.of(
                                                            context)
                                                        .textTheme
                                                        .headline6!
                                                        .copyWith(
                                                            color: Colors.white,
                                                            fontSize: 18),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 2.5,
                                                            horizontal: 6),
                                                    isCollapsed: true,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: concernedList.length,
                  ),
                ),
              ),
            ]);
          }),
        ),
      ),
    );
  }
}

class FirstRow extends StatefulWidget {
  FirstRow(
    this._descriptionController,
    this.fileList,
  );
  // super(key: key);

  final TextEditingController _descriptionController;
  // File?
  final List<File> fileList;

  @override
  _FirstRowState createState() => _FirstRowState();
}

class _FirstRowState extends State<FirstRow> {
  var pickedFile;
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    var tile = await picker.getImage(source: source);
    if (tile != null) {
      widget.fileList.add(File(tile.path));
    } else {
      print('No image selected.');
    }
    Navigator.of(context).pop();
    setState(() {
      pickedFile = tile;
    });
  }

  void _removeImage() {
    widget.fileList.removeAt(0);
    setState(() {
      pickedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // width: 300,
          child: Padding(
            padding: EdgeInsets.only(top: 3),
            child: TextFormField(
              controller: widget._descriptionController,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.black87),
              decoration: new InputDecoration(
                errorStyle: TextStyle(height: 0, fontSize: 0),
                isDense: true,
                prefixIcon: Container(
                  child: Icon(
                    Icons.description_outlined,
                    color: Colors.black87,
                    size: 26,
                  ),
                ),
                labelText: "Description",
                labelStyle: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: Colors.black54),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(),
                ),
              ),
              validator: (String? value) {
                if (value!.isEmpty) return '';
                return null;
              },
            ),
          ),
        ),
        Container(
          width: 55,
          margin: EdgeInsets.only(left: 5, right: 5),
          child: pickedFile != null
              ? GestureDetector(
                  onTap: _removeImage,
                  child: Container(
                    width: 55,
                    height: 52,
                    child: Image.file(File(pickedFile.path)),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.green[700],
                    size: 38,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                        barrierColor: Colors.black26,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        context: context,
                        builder: (context) => Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 25),
                              height: 195,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      height: 4.0,
                                      color: Colors.grey[500],
                                      width: 55,
                                    ),
                                  ),
                                  Text(
                                    'Add photo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(color: Colors.black87),
                                  ),
                                  SizedBox(height: 24),
                                  GestureDetector(
                                      onTap: () {
                                        _pickImage(ImageSource.gallery);
                                      },
                                      child: Row(children: [
                                        Icon(
                                          Icons.file_upload,
                                          color: Colors.grey.shade600,
                                          size: 31,
                                        ),
                                        SizedBox(width: 20),
                                        Text(
                                          'Upload from gallery',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(color: Colors.black87),
                                        )
                                      ])),
                                  Divider(
                                      color: Colors.grey.shade300, height: 20),
                                  GestureDetector(
                                      onTap: () {
                                        _pickImage(ImageSource.camera);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.camera_alt_sharp,
                                            color: Colors.grey.shade600,
                                            size: 31,
                                          ),
                                          SizedBox(width: 20),
                                          Text(
                                            'Use Camera',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6!
                                                .copyWith(
                                                    color: Colors.black87),
                                          )
                                        ],
                                      ))
                                ],
                              ),
                            ));
                  },
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                ),
        ),
      ],
    );
  }
}
