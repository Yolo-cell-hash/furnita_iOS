import 'package:flutter/material.dart';

class IvPasswordProvider with ChangeNotifier {
  String _newIV = '';
  String _newPass = '';
  String _unlockCmd = '';

  String get newIV => _newIV;
  String get newPass => _newPass;
  String get unlockCmd => _unlockCmd;

  void updateIV(String iv) {
    _newIV = iv;
    notifyListeners();
  }

  void updatePass(String pass) {
    _newPass = pass;
    notifyListeners();
  }

  void updateUnlockCmd(String cmd) {
    _unlockCmd = cmd;
    notifyListeners();
  }
}
