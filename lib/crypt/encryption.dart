import 'package:dummycastle/pl/polinc/dummycastle/dummycastle.dart';
import 'package:rubisco/session/globals.dart';

class Encryption {
  DummyCastle dummyCastle = DummyCastle();
  // so you can't share keys :cool:
  String password = states['enc'] + states['deviceId'];

  Encryption() {
    dummyCastle.genSymmKeyWith(password);
  }

  String encryptKey(int key) {
    return dummyCastle.encryptSymmWith(key.toString()).getResult();
  }

  int decryptKey(String key) {
    String decrypted = dummyCastle.decryptSymmWith(key).getResult();
    String decodedResult = dummyCastle.decodeWith(decrypted).toStringDecoded();

    return int.parse(decodedResult);
  }
}
