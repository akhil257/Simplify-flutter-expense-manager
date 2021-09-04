// import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simplify/helpers/constants.dart';
import 'package:simplify/helpers/snack.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore db = FirebaseFirestore.instance;

class Login extends StatefulWidget {
  Login({required this.isLogin});
  final bool isLogin;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool isPhone = false;
  bool otpSent = false;
  String country = 'NA';
  String currencyISO = 'NA';
  String currencyCode = '\u0024';
  String phoneCode = '1';
  late bool isLogin;
  late String _verificationId;
  static const double w = double.infinity;
  String avatarUrl = '';
  Future<void> getData() async {
    try {
      var url = Uri.parse(
          'http://ip-api.com/json/?fields=status,message,country,countryCode,currency');
      var response = await http.get(url);
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      setState(() {
        country = jsonData['countryCode'];
        currencyISO = jsonData['currency'];
        currencyCode = currency[currencyISO] ?? '\u0024';
        phoneCode = codes[country] ?? '1';
      });
    } catch (e) {
      print('Throwing error????????????');
      print(e);
      print(e.toString());
    }
  }

  @override
  void initState() {
    print(">>>>>>>>>>");
    isLogin = widget.isLogin;
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    var mData = MediaQuery.of(context);
    print(">>>>>>>>>>>>");
    double kheight =
        mData.size.height - mData.padding.top - mData.padding.bottom;

    return Scaffold(
      backgroundColor: Color.fromRGBO(5, 18, 44, 1),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
            height: kheight,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Spacer(
                        flex: 4,
                      ),
                      Expanded(
                        flex: 20,
                        child: Image.asset(
                          'assets/images/bill.png',
                          // height: 180,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Welcome to Simplify',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(fontSize: 24),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        'Split bill with friends and in groups,\nkeep track of all your expenses',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            height: 1.3,
                            color: Colors.white),
                      ),
                      Spacer(
                        flex: 3,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            isPhone
                                ? TextContainer(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: _phoneNumberController,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                      decoration: new InputDecoration(
                                          prefixIcon: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '+' + phoneCode,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6,
                                              ),
                                            ],
                                          ),
                                          // prefixText: '+'+phoneCode,
                                          // prefix: Text('+'+phoneCode,style: Theme.of(context).textTheme.headline6,),
                                          // prefixStyle: Theme.of(context).textTheme.headline6,
                                          hintText: "Phone no.",
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(color: Colors.white60),
                                          border: InputBorder.none),
                                      validator: (String? value) {
                                        if (!RegExp(r"^[1-9]{1}[0-9]{9}$")
                                            .hasMatch(value!)) {
                                          showSnack(
                                              context,
                                              "Enter a valid Mobile number",
                                              true);
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                                : TextContainer(
                                    child: TextFormField(
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                      keyboardType: TextInputType.emailAddress,
                                      controller: _emailController,
                                      decoration: new InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.email,
                                            color: Colors.white54,
                                          ),
                                          hintText: "Email",
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(color: Colors.white60),
                                          border: InputBorder.none),
                                      validator: (String? value) {
                                        if (!RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(value!)) {
                                          showSnack(context,
                                              "Enter a valid Email id", true);
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                            if (!isLogin)
                              TextContainer(
                                child: TextFormField(
                                  controller: _nameController,
                                  style: Theme.of(context).textTheme.headline6,
                                  decoration: new InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: Colors.white54,
                                      ),
                                      hintText: "Name",
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(color: Colors.white60),
                                      border: InputBorder.none),
                                  validator: (String? value) {
                                    if (value!.isEmpty || value.length < 3) {
                                      showSnack(context,
                                          "Invalid name. Too short", true);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            isPhone
                                ? TextContainer(
                                    child: TextFormField(
                                      controller: _otpController,
                                      keyboardType: TextInputType.number,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                      decoration: new InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.lock,
                                            color: Colors.white54,
                                          ),
                                          hintText: "OTP",
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(color: Colors.white60),
                                          border: InputBorder.none),
                                      obscureText: true,
                                    ),
                                  )
                                : TextContainer(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                      decoration: new InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.lock,
                                            color: Colors.white54,
                                          ),
                                          hintText: "Password",
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(color: Colors.white60),
                                          border: InputBorder.none),
                                      validator: (String? value) {
                                        if (value!.isEmpty ||
                                            value.length < 6) {
                                          showSnack(context,
                                              "Password too short", true);
                                        }

                                        return null;
                                      },
                                      obscureText: true,
                                    ),
                                  ),
                            // Spacer(flex: 1,),
                          ],
                        ),
                      ),
                      Spacer(
                        flex: isLogin ? 1 : 2,
                      ),
                      isPhone
                          ? Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 6),
                              child: ElevatedButton(
                                child: Text(otpSent
                                    ? isLogin
                                        ? "Login"
                                        : "Register"
                                    : "Request OTP"),
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState!.validate()) {
                                    otpSent
                                        ? _signInWithPhoneNumber(
                                            context, isLogin)
                                        : isLogin
                                            ? _verifyPhoneNumber(
                                                context, isLogin)
                                            : selectAvatar(
                                                _verifyPhoneNumber, 1);
                                  }
                                },
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 5),
                              child: ElevatedButton(
                                child: Text(
                                  isLogin ? "Login" : "Register",
                                ),
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState!.validate()) {
                                    isLogin
                                        ? _login(context)
                                        : selectAvatar(_registerWithMail, 0);
                                  }
                                },
                              ),
                            ),
                      isPhone
                          ? Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 6),
                              child: ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    isPhone = !isPhone;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue[700],
                                  shadowColor: Colors.blue[700],
                                ),
                                child: Text(isLogin
                                    ? "Sign in with Email"
                                    : "Sign up with Email"),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 6),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue[700],
                                  shadowColor: Colors.blue[700],
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    isPhone = !isPhone;
                                  });
                                },
                                child: Text(
                                  isLogin
                                      ? "Sign in with Phone"
                                      : "Sign up with Phone",
                                ),
                              ),
                            ),
                      Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white.withOpacity(0.85),
                            shadowColor: Colors.white24,
                          ),
                          onPressed: () {
                            isLogin
                                ? signInWithGoogle(context, true)
                                : selectAvatar(signInWithGoogle, 2);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                './assets/images/google.png',
                                height: 23,
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  isLogin
                                      ? " Sign in with Google"
                                      : " Sign up with Google",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer(flex: 1),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(
                          isLogin
                              ? "Don't have an account? Sign up"
                              : "Already have an account? Sign in",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Spacer(flex: 1),
                      if (isLogin)
                        TextButton(
                          onPressed: isPhone
                              ? null
                              : () async {
                                  if (!RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(_emailController.text)) {
                                    showSnack(context, "Invalid email", true);
                                    return;
                                  }
                                  try {
                                    await _auth.sendPasswordResetEmail(
                                        email: _emailController.text);
                                    showSnack(
                                        context,
                                        "Password reset link is sent to " +
                                            _emailController.text,
                                        false);
                                  } on FirebaseAuthException catch (e) {
                                    print(e.message);
                                    print(e.code);
                                    if (e.code.trim() == "user-not-found")
                                      showSnack(context,
                                          "Email id not registered", true);
                                    else
                                      showSnack(context,
                                          "Password reset failed", true);
                                  } catch (e) {
                                    showSnack(
                                        context, "Password reset failed", true);
                                  }
                                },
                          child: Text(
                            isPhone ? "" : "Forgot Password",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      Spacer(flex: 5),
                    ],
                  ),
                ),
              ],
            )),
      )),
    );
  }

  void _verifyPhoneNumber(ctx, isLogin) async {
    if (!RegExp(r"^[1-9]{1}[0-9]{9}$").hasMatch(_phoneNumberController.text))
      return;

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      _otpController.text = phoneAuthCredential.smsCode!;
      UserCredential user =
          await _auth.signInWithCredential(phoneAuthCredential);

      if (user.additionalUserInfo!.isNewUser && !isLogin) {
        print('new user');
        _register(ctx, user);
      }
      Navigator.pop(context);
    };

    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      print('The provided phone number is not valid.');
      showSnack(ctx, "Phone number verification failed", true);
      //   //     'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      print("check phone");
      showSnack(ctx, "OTP sent", false);
      _verificationId = verificationId;
      setState(() {
        otpSent = true;
      });
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      showSnack(context, "OTP sent", false);
      setState(() {
        otpSent = true;
      });
    };

    QuerySnapshot userCheck = await FirebaseFirestore.instance
        .collection('users')
        .where('phone',
            isEqualTo: '+' + phoneCode + _phoneNumberController.text)
        .get();

    if (userCheck.size < 1 && isLogin) {
      showSnack(ctx, "No user found", true);
    } else if (userCheck.size < 1 || isLogin) {
      try {
        await _auth.verifyPhoneNumber(
            phoneNumber: '+' + phoneCode + _phoneNumberController.text,
            timeout: const Duration(seconds: 5),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      } catch (e) {
        if (isLogin)
          showSnack(ctx, "Login failed", true);
        else
          showSnack(ctx, "Registration failed", true);
      }
    } else {
      showSnack(ctx, "Number already Registered", true);
    }
  }

  void _signInWithPhoneNumber(ctx, isLogin) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      UserCredential user = await _auth.signInWithCredential(credential);
      if (user.additionalUserInfo!.isNewUser && !isLogin) {
        print('new user');
        _register(ctx, user);
      }
      if (isLogin)
        showSnack(ctx, "Login Successful", false);
      else
        showSnack(ctx, "Registration Successful", false);
      Navigator.pop(ctx);
    } catch (e) {
      print(e);
      if (isLogin)
        showSnack(ctx, "Login Failed", true);
      else
        showSnack(ctx, "Registration Failed", true);
    }
  }

  void signInWithGoogle(ctx, bool _) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      print(googleUser!.email);
      // return;
      if (isLogin) {
        QuerySnapshot a = await db
            .collection('users')
            .where('email', isEqualTo: googleUser.email)
            .get();
        if(a.size<1){
          showSnack(context, 'No user found for this mail. Please signup', true);
          return;
        }
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // print(googleAuth.)

      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ) as GoogleAuthCredential;
      // print(credential.)

      UserCredential user =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (user.additionalUserInfo!.isNewUser) {
        await db.collection("users").doc(user.user!.uid).set({
          "email": user.user!.email ?? '',
          "phone": user.user!.phoneNumber ?? '',
          "name": user.user!.displayName,
          "friends": [],
          "groups": [],
          'img': avatarUrl,
          "tokens": "",
          "get": 0,
          "pay": 0,
          "total": 0,
          "country": country,
          "currency": currencyISO,
          "currencyCode": currencyCode,
          "phoneCode": phoneCode,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  void _login(ctx) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnack(ctx, "No user found for this email.", false);
      } else if (e.code == 'wrong-password') {
        showSnack(ctx, "Wrong password provided for that user.", true);
      } else {
        print(e.code + e.message!);
      }
    }
  }

  void _registerWithMail(ctx, bool isLogin) async {
    try {
      final UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _register(ctx, user);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        showSnack(ctx, "Password provided is too weak.", true);
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        showSnack(ctx, "Account already exists for that email.", true);
      }
    } catch (e) {
      print(e);
    }
  }

  void _register(ctx, UserCredential user) async {
    await db.collection("users").doc(user.user!.uid).set({
      "email": user.user?.email ?? '',
      "phone": user.user?.phoneNumber ?? '',
      "name": _nameController.text[0].toUpperCase() +
          _nameController.text.substring(1).toLowerCase(),
      'img': avatarUrl,
      "friends": [],
      "groups": [],
      "tokens": "",
      "get": 0,
      "pay": 0,
      "total": 0,
      "country": country,
      "currency": currencyISO,
      "currencyCode": currencyCode,
      "phoneCode": phoneCode,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  void selectAvatar(Function fun, int code) async {
    if (code == 0) {
      if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(_emailController.text)) {
        return;
      }
      if (_passwordController.text.isEmpty ||
          _passwordController.text.length < 6) {
        return;
      }
    } else if (code == 1) {
      if (!RegExp(r"^[1-9]{1}[0-9]{9}$")
          .hasMatch(_phoneNumberController.text)) {
        return;
      }
    }

    if ((code == 0 || code == 1) &&
        (_nameController.text.isEmpty || _nameController.text.length < 3)) {
      return;
    }
    showModalBottomSheet(
        barrierColor: Colors.black26,
        backgroundColor: Colors.blueGrey[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        context: context,
        builder: (ctx) => Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
              height: 595,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      height: 4.0,
                      color: Colors.white70,
                      width: 55,
                    ),
                  ),
                  Text(
                    'Select an Avatar',
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white70),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Expanded(
                    child: GridView.count(
                        primary: false,
                        // padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 13,
                        mainAxisSpacing: 13,
                        crossAxisCount: 4,
                        children: avatars
                            .map((e) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      avatarUrl = e;
                                    });
                                    Navigator.of(context).pop();
                                    fun(context, isLogin);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: new BoxDecoration(
                                      border: Border.all(
                                        width: 1.2,
                                        color: Colors.green.shade500,
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
                                          image: new NetworkImage(e),
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList()),
                  ),
                ],
              ),
            ));
  }

  // child:

  var avatars = [
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/snowboarder.png?alt=media&token=9b0a4006-cb2b-4d11-87da-ac75144bb256',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/10.png?alt=media&token=82ff57c2-247e-420a-b687-0b7189ff6586',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/cyclist.png?alt=media&token=a5fc30f0-3c93-4e37-9d20-04994f157e0b',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/1.png?alt=media&token=49deca42-e1ba-42bb-a085-d2fba46f8005',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/girl.png?alt=media&token=d71e9727-b100-48dd-b79b-6c7b1b337f5e',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/catcher.png?alt=media&token=a8a7a942-776e-4083-a6b1-289fdaa51e45',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/4.png?alt=media&token=aeca4dbe-8c1b-4fe5-9d5b-249acd1a14ef',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/5.png?alt=media&token=fdccab05-688e-4f2a-bb62-01e67f544591',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/6.png?alt=media&token=50c5370c-a6a1-488f-9077-eb477dd346bf',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/7.png?alt=media&token=1d267b99-8925-4388-8879-bbb18463faee',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/8.png?alt=media&token=7abde1d9-f3bf-4f16-ad50-6c7eeaf8d3bc',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/11.png?alt=media&token=72030712-f24c-4aaf-b8f5-935f9e0e9a62',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/13.png?alt=media&token=52270f42-2700-4ae7-b005-451a1ce2492a',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/14.png?alt=media&token=3b9ae911-1b67-48cb-a670-fb55dda9fa4a',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/diver.png?alt=media&token=5c12a83e-7313-47da-b390-a894d2801fb7',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/football.png?alt=media&token=10a6ae1a-4c67-4e0f-800e-66b2c21033b1',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/basketball-player.png?alt=media&token=cab206eb-bce3-453e-a3d4-8997f00da1f1',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/boxer.png?alt=media&token=886bc70e-22f2-4487-a3fc-8c07c8f8e468',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/gymnast.png?alt=media&token=70bf14b6-3245-44b0-b55b-4d8ada09e301',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/horsewoman.png?alt=media&token=4442dbd3-c13e-4e90-8d60-da0cf60f0047',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/knight.png?alt=media&token=ff2db453-e4e5-4b89-b2aa-7bdb17cca3ea',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/tennis-player.png?alt=media&token=f0c37d8a-1fd0-4fef-8b63-7b92731a2863',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/12.png?alt=media&token=bb400ee2-b904-4788-9de5-c229f29ded98',
    'https://firebasestorage.googleapis.com/v0/b/simplify-54f5d.appspot.com/o/9.png?alt=media&token=3c6066da-8879-4ceb-91ef-893c4b0e98ae',
  ];
}

class TextContainer extends StatelessWidget {
  TextContainer({required this.child});
  final TextFormField child;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 6),
      padding: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
          color: Colors.white12, borderRadius: BorderRadius.circular(15)),
      child: child,
    );
  }
}
