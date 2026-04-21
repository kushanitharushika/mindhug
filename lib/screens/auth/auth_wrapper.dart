import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Returns true if the current user needs to take the quiz.
  /// Priority: Firestore `lastQuizDate` > never taken.
  Future<bool> _isQuizDue() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return true; // no user → force quiz (safety)

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || !doc.data()!.containsKey('lastQuizDate')) {
        return true; // never taken for this account
      }

      final lastQuizDate = doc.data()!['lastQuizDate'];
      DateTime? lastDate;

      if (lastQuizDate is Timestamp) {
        lastDate = lastQuizDate.toDate();
      } else if (lastQuizDate is String) {
        lastDate = DateTime.tryParse(lastQuizDate);
      }

      if (lastDate == null) return true;

      final daysSince = DateTime.now().difference(lastDate).inDays;
      return daysSince >= 7;
    } catch (e) {
      debugPrint('QuizGuard Firestore check error: $e');
      // Fallback to local if Firestore fails
      return LocalStorage.isQuizDue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isQuizDue(),
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

