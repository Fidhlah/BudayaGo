import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../chatbot/chatbot_screen.dart';

class MainScreen extends StatefulWidget {
  final String? mascot;

  const MainScreen({Key? key, this.mascot}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize providers if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      // Initialize if not already initialized
      if (homeProvider.userXP == 0 && homeProvider.userLevel == 1) {
        homeProvider.initializeUserData();
      }

      // Load profile if not loaded
      if (!profileProvider.hasProfile) {
        // Will use AuthProvider userId in future
        profileProvider.loadProfile('default-user');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      ProfileScreen(mascot: widget.mascot ?? 'default'),
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
                        ChatbotScreen(mascot: widget.mascot ?? 'default'),
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
