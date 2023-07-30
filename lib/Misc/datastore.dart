import 'package:localstorage/localstorage.dart';
import 'package:rubisco_one/globals.dart';

final LocalStorage storage = LocalStorage("RubiscoData.json");

void saveData(Map<String, dynamic> value) {
  storage.setItem("RubiscoData.json", value);
}

Future<Map<String, dynamic>?> getData() async {
  await storage.ready;
  if (storage.getItem("RubiscoData.json") == null) {
    print("is null");
    saveData(g);
  }
  Map<String, dynamic> data = storage.getItem("RubiscoData.json");
  return data;
}
