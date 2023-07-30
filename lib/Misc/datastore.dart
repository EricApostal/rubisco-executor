import 'package:localstore/localstore.dart';

final db = Localstore.instance;

void saveData(String dbName, Map<String, dynamic> allData) {
    // gets new id
  final id = db.collection(dbName).doc().id;

  // save the item
  print(allData);
  db.collection(dbName).doc(id).set(allData);
}

Future<Map<String, dynamic>?> getData(String dbName) async {
  final id = db.collection(dbName).doc().id;
  return db.collection(dbName).doc(id).get();
}