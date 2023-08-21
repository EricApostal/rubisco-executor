import 'package:localstorage/localstorage.dart';
import 'package:rubisco/session/globals.dart';

final LocalStorage storage = LocalStorage("RubiscoData.json", "bin");

void saveData(Map<String, dynamic> value) {
  storage.setItem("RubiscoData.json", value);
}

Future<Map<String, dynamic>?> getData() async {
  await storage.ready;
  if (storage.getItem("RubiscoData.json") == null) {
    print("data is null, saving blank");
    saveData(g);
  }
  Map<String, dynamic> data = storage.getItem("RubiscoData.json");
  return data;
}
