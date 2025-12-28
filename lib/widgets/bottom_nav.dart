import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/exercises/exercises_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/chatbot/melo_chat_screen.dart';
import '../screens/profile/profile_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const ExercisesScreen(),
    const JournalScreen(),
    const MindHugChatbot(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: "Exercises",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Melo"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
