import 'package:flutter/material.dart';
import 'package:simplify/screens/login.dart';
// import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

class NewAuth extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    // print(">>>>>>>>>>>>>>>>>>>>>>>>>>");
    // print(FlutterSimCountryCode.simCountryCode);
    // print(">>>>>>>>>>>>>>>>>>>>>>>>>>");

    return Scaffold(
      backgroundColor: const Color.fromRGBO(5, 18, 44, 1),
      body: Column(
        children: [
          const Spacer(),
          const Spacer(),
          Image.asset(
            'assets/images/bill.png',
            height: 220,
          ),
          const Spacer(),
          Text(
            'Welcome to Simplify',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Split bill with friends and in groups,\nkeep track of all your expenses',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 19,
                height: 1.3,
                color: Colors.white),
          ),
          Spacer(),
          Container(
            height: 50,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 50),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Login(
                              isLogin: true,
                            )));
              },
              child: Text(
                'LOGIN',
                style: TextStyle(letterSpacing: 1.2, fontSize: 20),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Login(
                              isLogin: false,
                            )));
              },
              child: Text(
                "Don't have an account? Sign up",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              )),
          Spacer(),
        ],
      ),
    );
  }
}
