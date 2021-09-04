import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:simplify/helpers/snack.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class NewGroup extends StatefulWidget {
  NewGroup(this.data, this.uid);
  final String uid;
  final Map<String, dynamic> data;
  @override
  _NewGroupState createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<dynamic> recentList = [];
  List<dynamic> list = [];
  List<dynamic> concernedList = [];
  List<File> fileList = [];
  @override
  void initState() {
    super.initState();
    list = widget.data['friends'] + [];
    recentList = widget.data['friends'] + [];
    concernedList.add({
      'uid': widget.uid,
      'img': widget.data['img'],
      'name': widget.data['name'],
      'value': 0,
      'email': widget.data['email'],
      'phone': widget.data['phone']
    });
  }

  void _add() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference ref = await db.collection('groups').add(
          {
            'currency': 'INR',
            'users': concernedList,
            'img': '4',
            'name': _nameController.text[0].toUpperCase() +
                _nameController.text.substring(1),
            'createdBy': widget.uid,
            'createdByName': widget.data['name'],
            'createdAt': Timestamp.now(),
            'total': 0,
            'totalExpense': 0,
            'groupType': isSel.indexOf(true),
            'isDeleted': false,
            'isProcessed': false
          },
        );
        // if (fileList.length > 0) {
        //   await firebase_storage.FirebaseStorage.instance
        //       .ref('groups/${ref.id}.png')
        //       .putFile(fileList[0]);
        // }
        showSnack(context,  _nameController.text+" created", false);
        Navigator.pop(context);
      } catch (e) {
        showSnack(context, 'Failed', true);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void addToList(index, data) {
    setState(() {
      recentList.removeAt(index);
      list.removeWhere((item) => item['uid'] == data['uid']);
      data['value'] = 0;
      concernedList.add(data);
    });
  }

  void removeConcerned(data) {
    setState(() {
      recentList.add(data);
      concernedList.removeWhere((item) => item['uid'] == data['uid']);
      list.add(data);
    });
  }

  bool isSelected = true;
  List<bool> isSel = [false, false, false, true];

  @override
  Widget build(BuildContext context) {
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
                          //  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 0),
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
              ' NEW GROUP.',
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
              onPressed: _add,
              child: Text(
                'Create Group',
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
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  children: [
                    FirstRow(_nameController),
                    SizedBox(height: 14),
                    Container(
                      width: 500,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return ToggleButtons(
                          borderRadius: BorderRadius.circular(55),
                          selectedColor: Colors.green.shade600,
                          constraints: BoxConstraints.expand(
                              height: 40,
                              width: (constraints.maxWidth - 6) / 4),
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.home),
                                Text(
                                  'Home',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.black.withOpacity(0.75),
                                          fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.apartment),
                                Text(
                                  'Flat',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.black.withOpacity(0.75),
                                          fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.flight),
                                Text(
                                  'Trip',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.black.withOpacity(0.75),
                                          fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Other',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.black.withOpacity(0.75),
                                          fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < isSel.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  isSel[buttonIndex] = !isSel[buttonIndex];
                                } else {
                                  isSel[buttonIndex] = false;
                                }
                              }
                            });
                          },
                          isSelected: isSel,
                        );
                      }),
                    ),
                    SizedBox(height: 14),
                    //ThirdRow
                    Row(
                      children: [
                        Expanded(
                          flex: 9,
                          child: TextField(
                            controller: _searchController,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.black87, fontSize: 16),
                            onChanged: (String query) {
                              setState(() {
                                recentList = list
                                    .where((elem) => elem['name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(query.toLowerCase()))
                                    .toList();
                              });
                            },
                            cursorColor: Colors.black26,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 20),
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
                                      color: Colors.black54, fontSize: 16),
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(26.0),
                                borderSide: new BorderSide(
                                    style: BorderStyle.none, width: 0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    //FriendsList row
                    if (recentList.length > 0)
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        height: 95,
                        child: ListView.builder(
                          itemCount: recentList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => addToList(index, recentList[index]),
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 68,
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 2.4,
                                          color: Colors.green[500]!,
                                        ),
                                        image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: new NetworkImage(
                                              recentList[index]['img']),
                                        ),
                                      ),
                                      width: 68,
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      recentList[index]['name'].split(" ")[0],
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
                    //concerned list
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                    color: Color.fromRGBO(5, 18, 44, 1),
                  ),
                  child: GridView.count(
                      primary: false,
                      // padding: const EdgeInsets.all(20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 0,
                      crossAxisCount: 3,
                      children: <Widget>[
                        ...concernedList
                            .map(
                              (data) => Container(
                                padding: EdgeInsets.all(6),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: widget.uid == data['uid']
                                          ? null
                                          : () {
                                              removeConcerned(data);
                                            },
                                      child: Stack(children: [
                                        Container(
                                          height: 68,
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                              fit: BoxFit.contain,
                                              image:
                                                  new NetworkImage(data['img']),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            right: 10,
                                            top: 0,
                                            child: Container(
                                              width: 26,
                                              height: 26,
                                              child: Icon(
                                                Icons.cancel_rounded,
                                                color: widget.uid == data['uid']
                                                    ? Colors.grey
                                                    : Colors.amber,
                                                size: 26,
                                              ),
                                            ))
                                      ]),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(data['name'].split(" ")[0],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstRow extends StatelessWidget {
  FirstRow(
    this._descriptionController,
    // this.gImg,
  );
  // super(key: key);

  final TextEditingController _descriptionController;
  

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // width: 300,
          child: Padding(
            padding: EdgeInsets.only(top: 3),
            child: TextFormField(
              controller: _descriptionController,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.black87),
              decoration: new InputDecoration(
                errorStyle: TextStyle(height: 0, fontSize: 0),
                isDense: true,
                prefixIcon: Container(
                  // padding: EdgeInsets.only(left:9,top:8),
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
          // alignment: Alignment.center,
          margin: EdgeInsets.only(left: 5, right: 5),
          child: Container(
            padding: EdgeInsets.all(5),
            // width: 52,
            height: 72,
            decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.circular(8)),
            child: Image.asset(
              'assets/images/4.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
