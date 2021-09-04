import 'package:flutter/material.dart';

class HelperFunctions {
  Map<String, dynamic> split(List concernedList, String amt) {
    List split = [];
    List users = [];
    double totalPaid = 0;
    double totalOwed = 0;
    double totalAmount = double.parse(amt);
    print(amt);

    concernedList.forEach((e) {
      users.add(e['uid']);
      String paidString = (e['paidController'] as TextEditingController).text;
      String owedString = (e['owedController'] as TextEditingController).text;
      String totalString = (e['totalController'] as TextEditingController).text;
      double paid = double.parse(paidString == '' ? '0' : paidString);
      double owed = double.parse(owedString == '' ? '0' : owedString);

      totalPaid += paid;
      totalOwed += owed;
      split.add(
        {
          'uid': e['uid'],
          'name': e['name'],
          'img': e['img'],
          'paid': paid,
          'owes': owed,
          'total': paid - owed,
          'breakage': [],
          'tot':double.parse((paid - owed).toStringAsFixed(1)),
        },
      );
    });
    if ((totalAmount - totalPaid).abs() > 0.2 ||
        (totalAmount - totalOwed).abs() > 0.2 ||
        (totalAmount - totalPaid).abs() > 0.2) {
      throw new Exception('Amounts do not match');
    }
    bool toSolve = true;
    int i = 0;
    print('dxfcgkmlszdxfcghbj');
    while (toSolve && i < split.length - 1) {
      print(split);
      split.sort((a, b) => (a['tot'] as double).compareTo(b['tot']));
      if (split[0]["tot"] == 0) {
        toSolve = false;
        break;
      }
      print(i);

      int ln = split.length;

      double toReduce =
          -(split[0]['tot'] as double) < (split[ln - 1]['tot'] as double)
              ? -(split[0]['tot'] as double)
              : split[ln - 1]['tot'];
      toReduce = double.parse(toReduce.toStringAsFixed(1));

      split[0]["tot"] = split[0]["tot"] + toReduce;
      split[ln - 1]["tot"] = split[ln - 1]["tot"] - toReduce;
      var obj = {
        'uid': split[ln - 1]["uid"],
        'value': -toReduce,
      };
      (split[0]["breakage"] as List).add(obj);
      var obj1 = {
        'uid': split[0]["uid"],
        'value': toReduce,
      };
      (split[ln - 1]["breakage"] as List).add(obj1);
      i++;
    }
    split.forEach((element) {
      element.remove('tot');
    });
    print(split);

    return {
      'users': users,
      'split': split,
    };
  }
}
