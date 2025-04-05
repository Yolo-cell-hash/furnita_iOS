import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class Encryption {
  Uint8List encryptData(Uint8List data, String passcodeKey, Uint8List iv) {
    final key = Key.fromUtf8(passcodeKey.padRight(32, '\u0000'));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encryptBytes(data, iv: IV(iv));
    return encrypted.bytes;
  }

  String encryptDataStr(String data, String passcodeKey, Uint8List iv) {
    final key = Key.fromUtf8(passcodeKey.padRight(32, '\u0000'));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(data, iv: IV(iv));
    return base64.encode(encrypted.bytes);
  }
}
