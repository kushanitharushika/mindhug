import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/splash/splash_screen.dart'; // Import SplashScreen
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MindHugApp());
  } catch (e) {
    debugPrint("FIREBASE INIT FAILED: $e");
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Firebase initialization failed',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
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
          home: const SplashScreen(),
        );
      },
    );
  }
}
