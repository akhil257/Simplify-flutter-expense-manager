import 'package:flutter/material.dart';

class Dummy extends StatelessWidget {
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
      body: Column(
        children: [
          Spacer(),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
                color: const Color.fromRGBO(5, 18, 44, 1),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
