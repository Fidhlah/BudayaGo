import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../chat/chat_screen.dart';

class MainScreen extends StatefulWidget {
  final String? mascot;

  const MainScreen({Key? key, this.mascot}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int userXP = 150;
  int userLevel = 5;

  void _onXPGained(int xp) {
    setState(() {
      userXP += xp;
      if (userXP >= 100) {
        userLevel++;
        userXP = userXP % 100;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        mascot: widget.mascot ?? 'default',
        userXP: userXP,
        userLevel: userLevel,
        onXPGained: _onXPGained,
      ),
      ProfileScreen(
        mascot: widget.mascot ?? 'default',
        userXP: userXP,
        userLevel: userLevel,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ChatScreen(),
              ),
            );
          },
          icon: const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color:
                    _currentIndex == 0 ? Colors.orange.shade700 : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(
                Icons.person,
                color:
                    _currentIndex == 1 ? Colors.orange.shade700 : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
          ],
        ),
      ),
    );
  }
}
