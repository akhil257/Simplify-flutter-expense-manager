import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:simplify/helpers/const_widgets.dart';
import 'package:simplify/helpers/snack.dart';

FirebaseFunctions functions = FirebaseFunctions.instance;

class NewFriend extends StatefulWidget {
  NewFriend({required this.user, required this.friendsList});

  final Map<String, dynamic> user;
  final List friendsList;

  @override
  _NewFriendState createState() => _NewFriendState();
}

class _NewFriendState extends State<NewFriend> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isAlreadyAdded = false;
  bool isLoading = false;

  Map<String, dynamic> friend = {
    'uid': '',
    'name': '',
    'img': '',
    'email': '',
    'phone': '',
    'value': 0
  };

  void _addFriend() async {
    FocusScope.of(context).unfocus();
    if (isAlreadyAdded) {
      showSnack(context, 'User already in friends List', true);
      return;
    }
    if (friend['uid'] == widget.user['uid']) {
      showSnack(context, 'This is you', true);
      return;
    }
    if (friend['uid'] != null && friend['uid'] != "") {
      var toAdd = [widget.user, friend];

      try {
        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('addFriend');
        final HttpsCallableResult<dynamic> result =
            await callable({'toAdd': toAdd});
        // print(result.data);
        Navigator.popUntil(context, ModalRoute.withName("/"));
        showSnack(context, friend['name'] + ' added', false);
      } on FirebaseFunctionsException catch (e) {
        print(e);
        showSnack(context, e.message ?? '', true);
      } catch (e) {
        print(e);
        showSnack(context, "Something went wrong. Try after sometime", true);
      }
    } else {
      showSnack(context, 'Please enter mail or phone no', true);
    }
  }

  void _checkMail() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        String searchQuery = '';
        if (RegExp(r"^[1-9]{1}[0-9]{9}$").hasMatch(_searchController.text))
          searchQuery = '+' + widget.user['phoneCode'] + _searchController.text;
        else if (RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(_searchController.text))
          searchQuery = _searchController.text;
        else {
          showSnack(context, 'Not a valid email or phone no.', true);
          setState(() {
            isLoading = false;
          });
          return;
        }
        print(">>>>>>>>>>>");
        print(searchQuery);
        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('checkMail');
        final HttpsCallableResult<dynamic> result =
            await callable({'text': searchQuery});
        var i = widget.friendsList
            .indexWhere((element) => element['uid'] == result.data['uid']);
        setState(() {
          friend['uid'] = result.data['uid'];
          friend['name'] = result.data['name'];
          friend['email'] = result.data['email'];
          friend['phone'] = result.data['phone'];
          friend['img'] = result.data['img'];
          if (i < 0)
            isAlreadyAdded = false;
          else
            isAlreadyAdded = true;
          isLoading = false;
        });
      } on FirebaseFunctionsException catch (e) {
        print(e);
        showSnack(context, e.message ?? '', true);
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        showSnack(context, "Something went wrong. Try after sometime", true);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    print(screenSize);
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
              ' NEW FRIEND.',
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
              child: LoadButton(fun: _addFriend, text: 'Add Friend')),
        ],
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _searchController,
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: Colors.black87),
                        decoration: new InputDecoration(
                          errorStyle: TextStyle(height: 0, fontSize: 0),
                          isDense: true,
                          prefixIcon: Container(
                            child: Icon(
                              Icons.person_add_alt,
                              color: Colors.black87,
                              size: 26,
                            ),
                          ),
                          labelText: "Enter email or phone no.",
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
                          if (value!.isEmpty)
                            return 'Please enter email or phone no.';
                          return null;
                        },
                      ),
                      SizedBox(height: 6),
                      Text("Don't include extension codes for phone no.",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(fontSize: 12, color: Colors.black45)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _checkMail,
                        child: Text('Search'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25)),
                      color: const Color.fromRGBO(5, 18, 44, 1),
                    ),
                    child: friend['uid'] == ''
                        ? Center(
                            child: isLoading
                                ? CircularProgressIndicator(
                                    strokeWidth: 5,
                                    backgroundColor: Colors.green,
                                  )
                                : Text(
                                    'Search friends on Simplify by \nentering their emails or phone numbes',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                          )
                        : Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.only(right: 30),
                                        height: 74,
                                        width: 74,
                                        decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 2.4,
                                            color: Colors.green.shade500,
                                          ),
                                          image: new DecorationImage(
                                            fit: BoxFit.contain,
                                            image: new NetworkImage(
                                                friend['img']!),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(friend['name']!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(fontSize: 20)),
                                          if (friend['email'] != null &&
                                              friend['email'] != "")
                                            Text(friend['email'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2),
                                          if (friend['phone'] != null &&
                                              friend['phone'] != "")
                                            Text(friend['phone'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer()
                            ],
                          ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
