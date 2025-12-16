import 'package:flutter/material.dart';
//import 'screens/auth/login_screen.dart';
import 'screens/loading/loading_screen.dart';

void main() {
  runApp(const MindHugApp());
}

class MindHugApp extends StatelessWidget {
  const MindHugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindHug',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.purple, fontFamily: 'Poppins'),
      home: const LoadingScreen(),
    );
  }
}
