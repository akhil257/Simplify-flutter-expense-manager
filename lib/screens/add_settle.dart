import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:simplify/helpers/constants.dart';
import 'package:simplify/helpers/helperfunc.dart';
import 'package:simplify/helpers/snack.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class AddSettle extends StatefulWidget {
  AddSettle(
      {required this.data,
      required this.uid,
      required this.mode,
      required this.name,
      required this.completeData,
      required this.img});
  final String uid;
  final List<dynamic> data;
  final Map<String,dynamic> completeData;
  final String mode;
  final String name;
  final String img;

  @override
  _AddSettleState createState() => _AddSettleState();
}

class _AddSettleState extends State<AddSettle> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<dynamic> list = [];
  DateTime selectedDate = DateTime.now();
  List<dynamic> concernedList = [];
  bool isEqual = true;
  List<File> fileList = [];
  bool isGroup = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    bool friendPaid = true;
    String ownerPaidAmt = '';
    String ownerOwedAmt = '';
    String friendOwedAmt = '';
    String friendPaidAmt = '';

    if (widget.mode == 'Settle') {
      if (widget.data[0]['value'] < 0) {
        friendPaid = false;
        ownerPaidAmt = widget.data[0]['value'].abs().toString();
        friendOwedAmt = widget.data[0]['value'].abs().toString();
      } else {
        friendPaidAmt = widget.data[0]['value'].abs().toString();
        ownerOwedAmt = widget.data[0]['value'].abs().toString();
      }
      _amountController.text = widget.data[0]['value'].abs().toString();
      _descriptionController.text = 'Settled';
    }
    concernedList.add({
      'uid': widget.uid,
      'img': widget.img,
      'name': widget.name,
      'didPaid': widget.mode == 'Settle' ? !friendPaid : true,
      'didOwes': widget.mode == 'Settle' ? friendPaid : true,
      'paidController': TextEditingController(text: ownerPaidAmt),
      'owedController': TextEditingController(text: ownerOwedAmt),
      'totalController': TextEditingController(),
    });
    widget.data.forEach((element) {
      element['didPaid'] = widget.mode == 'Settle' ? friendPaid : false;
      element['didOwes'] = widget.mode == 'Settle' ? !friendPaid : true;
      element['paidController'] = TextEditingController(text: friendPaidAmt);
      element['owedController'] = TextEditingController(text: friendOwedAmt);
      element['totalController'] = TextEditingController();
      concernedList.add(element);
    });
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
        String desc = _descriptionController.text.split(" ").last;
        var imgUrl = 'c1';
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
        String downloadURL = '';
        try {
          String t = DateTime.now().toString();
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

          DocumentReference ref = await db.collection('transactions').add(
            {
              'txnType': 'added',
              'amount': _amountController.text,
              'currency': widget.completeData['currency'],
              'currencyCode':widget.completeData['currencyCode'],
              'users': splitted['users'],
              'concernedUsers': splitted['users'],
              'split': splitted['split'],
              'prevSplit': null,
              'icon': downloadURL,
              'imageUrl': imgUrl,
              'comment': null,
              'description': _descriptionController.text,
              'txnDate': selectedDate,
              'isEqual': isEqual,
              'isGroup': false,
              'groupId': null,
              'isParent': true,
              'parents': [],
              'prevParent': null,
              'isEdited': false,
              'isDeleted': false,
              'isProcessed': false,
              'createdBy': widget.uid,
              'createdByName': widget.name,
              'createdByImg': widget.img,
              'createdAt': Timestamp.now(),
            },
          );
          
          showSnack(context, 'Successfully added', false);
          Navigator.popUntil(context, ModalRoute.withName("/"));
        } catch (e) {
          showSnack(context, 'Failed', true);
          setState(() {
          isLoading = false;
        });
        }
      } catch (e) {
        showSnack(context, 'Amounts do not match', true);
        setState(() {
          isLoading = false;
        });
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
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
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

  void setAmount() {
    FocusScope.of(context).unfocus();
    var amt = int.parse(_amountController.text);
    int paidCount = 0;
    int owedCount = 0;
    if (isEqual) {
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

  bool isSelected = true;

  @override
  Widget build(BuildContext context) {
    // print(concernedList.length);
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
                              border:
                                  Border.all(color: Colors.black45, width: 1),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.chevron_left,
                              color: Colors.black54, size: 36),
                        )
                      ],
                    ),
                  )),
        ],
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
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
            height: 60,
            width: 250,
            margin: EdgeInsets.only(left: 25),
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
                    widget.mode == 'Settle' ? 'Settle' : 'Add Bill',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Column(
                    children: [
                      FirstRow(_descriptionController, fileList, widget.mode),
                      SizedBox(height: 16),
                      //secondrow
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
                                prefixIcon: Container(
                                  width: 20,
                                  margin: EdgeInsets.only(
                                      left: 18, top: 10, right: 0),
                                  child: Text(
                                    "${widget.completeData['currencyCode']}    ",
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
                                errorStyle: TextStyle(fontSize: 0, height: 0),
                                focusedErrorBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
                                  borderSide: new BorderSide(color: Colors.red),
                                ),
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(color: Colors.black54),
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
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
                                          color: Colors.black87, fontSize: 18),
                                ),
                                onPressed: () => _selectDate(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  )),

              //concerned list
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                    color: Color.fromRGBO(5, 18, 44, 1),
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(children: <Widget>[
                      ...concernedList
                          .map((data) => Container(
                                height: 102,
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              height: 64,
                                              decoration: new BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: new DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: new NetworkImage(
                                                      data['img']),
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
                                                      color: Colors.grey),
                                                ))
                                          ]),
                                    ),
                                    Expanded(
                                      flex: 14,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 18, right: 4),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 6),
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          data['name']
                                                                  .split(
                                                                      " ")[0] +
                                                              " ",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText1!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          19)),
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
                                                          onTap: widget.mode ==
                                                                  'Settle'
                                                              ? null
                                                              : () {
                                                                  paidClick(
                                                                      data);
                                                                },
                                                          child: Container(
                                                            // width: double.minPositive,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 3,
                                                                    horizontal:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: data['didPaid']
                                                                        ? Colors.green[
                                                                            500]
                                                                        : Colors
                                                                            .transparent,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                4),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                              .green[
                                                                          500]!,
                                                                      width: 1,
                                                                    )),
                                                            child: Text("Paid",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6!
                                                                    .copyWith(
                                                                        color: data['didPaid']
                                                                            ? Colors
                                                                                .white
                                                                            : Colors.green[
                                                                                500],
                                                                        fontSize:
                                                                            17)),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 95,
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .white12,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .green,
                                                                  width: 0.6)),
                                                          child: TextFormField(
                                                            // readOnly: !data['didPaid'],
                                                            enabled:
                                                                data['didPaid'],
                                                            onTap: null,

                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            cursorColor: Colors
                                                                .green[500],
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline6!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18),
                                                            textAlign:
                                                                TextAlign.end,
                                                            controller: data[
                                                                'paidController'],
                                                            decoration:
                                                                new InputDecoration(
                                                              prefixText:
                                                                  "${widget.completeData['currencyCode']} ",
                                                              prefixStyle: Theme
                                                                      .of(
                                                                          context)
                                                                  .textTheme
                                                                  .headline6!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18),
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                      vertical:
                                                                          2.5,
                                                                      horizontal:
                                                                          6),
                                                              isCollapsed: true,
                                                              border:
                                                                  InputBorder
                                                                      .none,
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
                                                      textAlign:
                                                          TextAlign.start,
                                                      controller: data[
                                                          'totalController'],
                                                      decoration:
                                                          new InputDecoration(
                                                        prefixText: "${widget.completeData['currencyCode']} ",
                                                        prefixStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyText2,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        2.5,
                                                                    horizontal:
                                                                        6),
                                                        isCollapsed: true,
                                                      ),
                                                    ),
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
                                                        onTap: widget.mode ==
                                                                'Settle'
                                                            ? null
                                                            : () {
                                                                owedClick(data);
                                                              },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 2,
                                                                  horizontal:
                                                                      4.5),
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: data['didOwes']
                                                                      ? Colors.red[
                                                                          800]
                                                                      : Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .red,
                                                                    width: 1,
                                                                  )),
                                                          child: Text(
                                                            "Owes",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline6!
                                                                .copyWith(
                                                                    color: data[
                                                                            'didOwes']
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .red,
                                                                    fontSize:
                                                                        17),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 95,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.white12,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .red[300]!,
                                                                width: 0.6)),
                                                        child: TextFormField(
                                                          // readOnly: !data['didPaid'],
                                                          enabled:
                                                              data['didOwes'],

                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          cursorColor:
                                                              Colors.red,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline6!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18),
                                                          textAlign:
                                                              TextAlign.end,
                                                          controller: data[
                                                              'owedController'],
                                                          decoration:
                                                              new InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            prefixText:
                                                                "${widget.completeData['currencyCode']} ",
                                                            prefixStyle: Theme
                                                                    .of(context)
                                                                .textTheme
                                                                .headline6!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18),
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            2.5,
                                                                        horizontal:
                                                                            6),
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
                              ))
                          .toList(),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstRow extends StatefulWidget {
  FirstRow(this._descriptionController, this.fileList, this.mode);

  final TextEditingController _descriptionController;
  final List<File> fileList;
  final String mode;

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
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
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
