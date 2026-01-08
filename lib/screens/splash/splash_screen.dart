import 'package:flutter/material.dart';
import '../auth/auth_wrapper.dart';
import '../../widgets/mindhug_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force Light Mode aesthetics
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Theme(
              data: ThemeData.light(),
              child: const MindHugLogo(size: 80), // Larger logo for splash
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
