import 'package:dummycastle/pl/polinc/dummycastle/dummycastle.dart';
import 'package:rubisco/globals.dart';

class Encryption {
  DummyCastle dummyCastle = DummyCastle();
  String password = states['enc'];

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