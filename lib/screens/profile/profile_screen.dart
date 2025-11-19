import 'package:flutter/material.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String mascot;
  final int userXP;
  final int userLevel;

  const ProfileScreen({
    Key? key,
    required this.mascot,
    required this.userXP,
    required this.userLevel,
  }) : super(key: key);

  IconData _getMascotIcon() {
    switch (mascot) {
      case 'Wayang':
        return Icons.theater_comedy;
      case 'Batik':
        return Icons.palette;
      case 'Keris':
        return Icons.auto_stories;
      case 'Angklung':
        return Icons.music_note;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectibles = [
      {'name': 'Kebaya', 'icon': Icons.checkroom},
      {'name': 'Batik', 'icon': Icons.palette},
      {'name': 'Rendang', 'icon': Icons.restaurant},
      {'name': 'Tari Saman', 'icon': Icons.music_note},
      {'name': 'Angklung', 'icon': Icons.piano},
      {'name': 'Wayang', 'icon': Icons.theater_comedy},
      {'name': 'Rumah Gadang', 'icon': Icons.home},
      {'name': 'Ulos', 'icon': Icons.checkroom},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Mascot
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.pink.shade300],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(_getMascotIcon(), size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                mascot,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pemandu Budayamu',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Statistik Gamifikasi
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Total XP',
                          userXP.toString(),
                          Icons.star,
                          Colors.amber,
                        ),
                        _buildStatItem(
                          'Level',
                          userLevel.toString(),
                          Icons.trending_up,
                          Colors.blue,
                        ),
                        _buildStatItem(
                          'Koleksi',
                          collectibles.length.toString(),
                          Icons.collections,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Koleksi
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Koleksiku',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: collectibles.length,
                itemBuilder: (context, index) {
                  final item = collectibles[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: Colors.orange.shade700,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['name'] as String,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Apakah kamu yakin ingin keluar?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const OnboardingScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
