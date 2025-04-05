import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furnita_ios/utils/iv_password_provider.dart';
import 'package:furnita_ios/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IvPasswordProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
