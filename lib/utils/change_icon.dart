import 'package:flutter/material.dart';

class SetIconForButton {
  SetIconForButton();

  dynamic logo, text;

  Widget changeLogo(bool state) {
    if (state) {
      logo = Icons.search;
    } else {
      logo = Icons.refresh;
    }
    return Opacity(
        opacity: 0.5,
        child: Icon(
          logo,
          color: Color(0xFFFFFFFF),
        ));
  }

  Widget changeText(bool state) {
    if (state) {
      text = 'Scan';
    } else {
      text = 'Re-scan';
    }
    return Opacity(
      opacity: 0.5,
      child: Text(
        text,
        style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 22.0),
      ),
    );
  }
}
