import 'package:flutter/material.dart';
import '../main/main_screen.dart';

class MascotResultScreen extends StatelessWidget {
  final String mascot;

  const MascotResultScreen({Key? key, required this.mascot}) : super(key: key);

  Map<String, dynamic> getMascotInfo() {
    final mascots = {
      'Wayang': {
        'name': 'Si Wayang',
        'description':
            'Kamu adalah pendongeng yang bijaksana! Kamu suka berbagi cerita dan makna mendalam.',
        'icon': Icons.theater_comedy,
      },
      'Batik': {
        'name': 'Si Batik',
        'description':
            'Kamu adalah kreator yang artistik! Kamu suka menciptakan sesuatu yang indah dan bermakna.',
        'icon': Icons.palette,
      },
      'Keris': {
        'name': 'Si Keris',
        'description':
            'Kamu adalah peneliti yang tajam! Kamu suka menggali pengetahuan secara mendalam.',
        'icon': Icons.auto_stories,
      },
      'Angklung': {
        'name': 'Si Angklung',
        'description':
            'Kamu adalah kolaborator yang harmonis! Kamu suka bekerja bersama dan menciptakan keselarasan.',
        'icon': Icons.music_note,
      },
    };
    return mascots[mascot] ?? mascots['Wayang']!;
  }

  @override
  Widget build(BuildContext context) {
    final info = getMascotInfo();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade300, Colors.blue.shade200],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    info['icon'],
                    size: 100,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Selamat!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pemandumu adalah',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  info['name'],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    info['description'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(mascot: mascot),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Mulai Petualangan!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
