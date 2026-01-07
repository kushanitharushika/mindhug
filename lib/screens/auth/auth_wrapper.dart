import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/bottom_nav.dart';
import 'login_screen.dart';
import '../loading/loading_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen(onFinish: () {});
        }
        
        if (snapshot.hasData) {
          return const BottomNav();
        }
        
        return const LoginScreen();
      },
    );
  }
}
