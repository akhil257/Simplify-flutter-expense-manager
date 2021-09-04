import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class FireHelpers {
  Future<bool> delete(QueryDocumentSnapshot txn, String uid) async{
    db.enableNetwork();
    var signedUser =
        (txn['split'] as List).firstWhere((element) => element['uid'] == uid);
    print(signedUser);
    Map<String, dynamic> deltxn = new Map.of(txn.data());
    List parentsList = txn['parents'];
    parentsList.add(txn.id);

    deltxn['txnType'] = 'deleted';
    deltxn['txnDate'] = Timestamp.now();
    deltxn['users'] = txn['concernedUsers'];
    deltxn['prevSplit'] = null;
    deltxn['isParent'] = false;
    deltxn['parents'] = parentsList;
    deltxn['prevParent'] = txn.id;
    deltxn['parent'] = txn["isParent"]?txn.id:txn["parent"];
    deltxn['isProcessed'] = false;
    deltxn['isEdited'] = false;
    deltxn['isDeleted'] = false;
    deltxn['createdBy'] = uid;
    deltxn['createdByName'] = signedUser['name'];
    deltxn['createdByImg'] = signedUser['img'];
    deltxn['createdAt'] = Timestamp.now();
    try{
      await db
        .collection('transactions')
        .add(deltxn);
        return true;
    }catch(e){
      return false;
    }
  }
}
