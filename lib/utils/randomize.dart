import 'dart:typed_data';
import 'dart:convert';

class IvJump {
  String password = "Qn5qd7i80vQvM0KFQLy0Qn5qd7i80Fco";
  String iv = "0vQvM0KFQLy0Qn5q";

  String replaceIVWithUID(String iv, String uid) {
    if (uid.length < 8) {
      throw ArgumentError('UID should be at least 8 characters long.');
    }
    final positions = [0, 2, 3, 7, 9, 11, 13, 15];
    List<String> ivChars = iv.split('');
    for (int i = 0; i < positions.length; i++) {
      ivChars[positions[i]] = uid[i];
    }
    final updatedIV = ivChars.join('');
    return updatedIV;
  }

  String replacePasswordWithUID(String password, String uid) {
    if (uid.length < 8) {
      throw ArgumentError('UID should be at least 8 characters long.');
    }
    final positions = [1, 4, 9, 10, 15, 19, 26, 30];
    List<String> passwordChars = password.split('');
    for (int i = 0; i < positions.length; i++) {
      passwordChars[positions[i]] = uid[i];
    }
    final updatedPassword = passwordChars.join('');
    print('## Updated password: $updatedPassword');
    return updatedPassword;
  }

// String? encrypt(Uint8List text, String key, String iv) {
//   try {
//     final keyBytes = encrypt1.Key.fromUtf8(key);
//     final ivBytes = encrypt1.IV.fromBase64(base64Encode(iv.codeUnits));
//     final encrypter = encrypt1.Encrypter(
//         encrypt1.AES(keyBytes, mode: encrypt1.AESMode.cbc));
//
//     // Encrypt the data
//     final encrypted = encrypter.encryptBytes(text, iv: ivBytes);
//
//     // Return Base64 encoded encrypted data
//     return encrypted.base64;
//   } catch (e) {
//     // Similar to Kotlin's error handling, return null on encryption failure
//     print('Encryption error: $e');
//     return null;
//   }
// }
}
