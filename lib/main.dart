import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'screens/auth/login_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MindHugApp());
}

class MindHugApp extends StatelessWidget {
  const MindHugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'MindHug',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          // Use AuthWrapper to decide between Login and Home
          home: const AuthWrapper(),
        );
      },
    );
  }
}
