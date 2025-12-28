import 'package:flutter/material.dart';
//import 'screens/auth/login_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';

void main() {
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
          home: const LoadingScreen(),
        );
      },
    );
  }
}
