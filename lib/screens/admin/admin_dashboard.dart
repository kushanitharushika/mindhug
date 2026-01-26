import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import 'admin_users_screen.dart';
import 'admin_quiz_screen.dart'; 
import 'admin_exercises_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminUsersScreen(),
    const AdminQuizScreen(),
    const AdminExercisesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // We don't use the standard bottom nav here, we want a dedicated admin look
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz),
              label: 'Quizzes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Exercises',
            ),
          ],
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}
