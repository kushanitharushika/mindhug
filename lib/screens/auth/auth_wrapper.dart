import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/bottom_nav.dart';
import 'login_screen.dart';
import '../loading/loading_screen.dart';
import '../../core/storage/local_storage.dart';
import '../quiz/mental_health_quiz.dart';
import '../admin/admin_dashboard.dart';

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
          return const RoleRouter();
        }
        
        return const LoginScreen();
      },
    );
  }
}

/// Checks user role and routes to the correct home screen.
class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AuthService().getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen(onFinish: () {});
        }

        // Admin gets their own dedicated dashboard
        if (snapshot.data == 'admin') {
          return const AdminDashboard();
        }

        // Regular user goes through quiz guard then main app
        return const QuizGuard();
      },
    );
  }
}

class QuizGuard extends StatelessWidget {
  const QuizGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: LocalStorage.isQuizDue(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen(onFinish: () {});
        }
        
        if (snapshot.data == true) {
          return const MentalHealthQuiz(isForced: true);
        }
        
        return const BottomNav();
      },
    );
  }
}
