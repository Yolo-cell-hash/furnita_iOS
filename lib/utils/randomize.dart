import 'dart:typed_data';
import 'dart:convert';

class IvJump {
  String password = "Oq7680vQvM0zc8m77m0KFQLy0vQvM0zc";
  String iv = "vM0zc8m77m0KFQLy";

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
}
