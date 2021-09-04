import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
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
                          margin: EdgeInsets.only(right: 20),
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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 10, right: 40),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromRGBO(5, 18, 44, 1)),
                      width: 80,
                      height: 80,
                      child: Image.asset(
                        'assets/images/bill.png',
                        fit: BoxFit.contain,
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simplify',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'v 1.1.1',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                        ),
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Simplify is an easy-to-use expense manager for splitting bills and expenses with friends, family and roommates.\n\nSimplify provides an easy way to keep track of your daily expenses and allows them to split with friends. Simplify is great for flatmates sharing, couples sharing relationship costs and much more. Went to movies, dinner or a vacation? Simplify can literally simplify your life by tracking who owes who and saving from the hassle of asking for money.\n\nSimplify comes with great features:\n- Create groups with friends.\n- Add bills, expenses, or simple debts with friends or in groups.\n- Search and add new friends.\n- Upload unlimited bill photos with details for free.\n- Notifications and real-time syncing of data.\n- All data is backed up in the cloud.\n- Add or remove friends from groups later.\n- Completely free to use !!\n\nFor feedback and queries contact us at akhil82395@gmail.com',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text('Attributions',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  if (await canLaunch(
                      'https://www.flaticon.com/authors/flat-icons')) {
                    await launch('https://www.flaticon.com/authors/flat-icons');
                  } else {
                    print("launch failed");
                  }
                },
                child: Text(
                  'Bill icon from Flat Icons',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  if (await canLaunch(
                      '"https://www.freepik.com')) {
                    await launch('"https://www.freepik.com');
                  } else {
                    print("launch failed");
                  }
                },
                child: Text(
                  'Other icons from Freepik',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
