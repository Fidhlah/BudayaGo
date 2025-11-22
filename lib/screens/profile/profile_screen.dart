import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  final String mascot;

  const ProfileScreen({Key? key, required this.mascot}) : super(key: key);

  IconData _getMascotIcon() {
    switch (mascot) {
      case 'Komodo':
        return Icons.pets;
      case 'Harimau':
        return Icons.shield;
      case 'Garuda':
        return Icons.flight;
      case 'Merak':
        return Icons.auto_awesome;
      case 'Orangutan':
        return Icons.favorite;
      case 'Gajah':
        return Icons.people;
      case 'Banteng':
        return Icons.flag;
      default:
        return Icons.star;
    }
  }

  List<Map<String, dynamic>> _getMascotArtifacts(String mascotName) {
    switch (mascotName) {
      case 'Komodo':
        return [
          {'name': 'Peta Kuno', 'icon': Icons.map, 'locked': false},
          {'name': 'Kompas Logika', 'icon': Icons.explore, 'locked': false},
          {'name': 'Kaca Pembesar', 'icon': Icons.search, 'locked': true},
          {'name': 'Buku Analisis', 'icon': Icons.book, 'locked': true},
          {'name': 'Kristal Biru', 'icon': Icons.diamond, 'locked': true},
        ];
      case 'Harimau':
        return [
          {
            'name': 'Pedang Keberanian',
            'icon': Icons.sports_martial_arts,
            'locked': false,
          },
          {'name': 'Perisai Gagah', 'icon': Icons.shield, 'locked': false},
          {'name': 'Mahkota Raja', 'icon': Icons.military_tech, 'locked': true},
          {'name': 'Taring Emas', 'icon': Icons.star, 'locked': true},
          {
            'name': 'Api Semangat',
            'icon': Icons.local_fire_department,
            'locked': true,
          },
        ];
      case 'Garuda':
        return [
          {'name': 'Sayap Cahaya', 'icon': Icons.flight, 'locked': false},
          {'name': 'Tasbih Suci', 'icon': Icons.spa, 'locked': false},
          {'name': 'Bulu Emas', 'icon': Icons.auto_awesome, 'locked': true},
          {'name': 'Kalung Mistik', 'icon': Icons.category, 'locked': true},
          {'name': 'Cawan Suci', 'icon': Icons.emoji_events, 'locked': true},
        ];
      case 'Merak':
        return [
          {'name': 'Palet Warna', 'icon': Icons.palette, 'locked': false},
          {'name': 'Kuas Ajaib', 'icon': Icons.brush, 'locked': false},
          {'name': 'Bulu Pelangi', 'icon': Icons.color_lens, 'locked': true},
          {'name': 'Kanvas Emas', 'icon': Icons.image, 'locked': true},
          {'name': 'Prisma Cahaya', 'icon': Icons.wb_sunny, 'locked': true},
        ];
      case 'Orangutan':
        return [
          {'name': 'Hati Emas', 'icon': Icons.favorite, 'locked': false},
          {'name': 'Bunga Kasih', 'icon': Icons.local_florist, 'locked': false},
          {
            'name': 'Permata Empati',
            'icon': Icons.auto_awesome,
            'locked': true,
          },
          {'name': 'Tangan Penolong', 'icon': Icons.back_hand, 'locked': true},
          {
            'name': 'Aura Hangat',
            'icon': Icons.wb_incandescent,
            'locked': true,
          },
        ];
      case 'Gajah':
        return [
          {'name': 'Gading Persatuan', 'icon': Icons.people, 'locked': false},
          {'name': 'Belalai Bijak', 'icon': Icons.psychology, 'locked': false},
          {
            'name': 'Mahkota Kepala',
            'icon': Icons.workspace_premium,
            'locked': true,
          },
          {'name': 'Kain Ceremonial', 'icon': Icons.checkroom, 'locked': true},
          {'name': 'Gong Komunitas', 'icon': Icons.campaign, 'locked': true},
        ];
      case 'Banteng':
        return [
          {'name': 'Tanduk Kuat', 'icon': Icons.flag, 'locked': false},
          {'name': 'Sabuk Prinsip', 'icon': Icons.security, 'locked': false},
          {'name': 'Batu Kokoh', 'icon': Icons.landscape, 'locked': true},
          {'name': 'Perisai Teguh', 'icon': Icons.verified, 'locked': true},
          {
            'name': 'Piagam Kehormatan',
            'icon': Icons.workspace_premium,
            'locked': true,
          },
        ];
      default:
        return [
          {'name': 'Artifact 1', 'icon': Icons.star, 'locked': false},
          {'name': 'Artifact 2', 'icon': Icons.star, 'locked': false},
          {'name': 'Artifact 3', 'icon': Icons.star, 'locked': true},
          {'name': 'Artifact 4', 'icon': Icons.star, 'locked': true},
          {'name': 'Artifact 5', 'icon': Icons.star, 'locked': true},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final artifacts = _getMascotArtifacts(mascot);
    final achievements = [
      {
        'name': 'Penjelajah Pemula',
        'desc': 'Selesaikan 5 eksplorasi',
        'icon': Icons.explore,
        'unlocked': true,
      },
      {
        'name': 'Kolektor Budaya',
        'desc': 'Kumpulkan 3 artifact',
        'icon': Icons.collections,
        'unlocked': true,
      },
      {
        'name': 'Master Budaya',
        'desc': 'Capai level 10',
        'icon': Icons.workspace_premium,
        'unlocked': false,
      },
      {
        'name': 'Ahli Sejarah',
        'desc': 'Baca 20 cerita budaya',
        'icon': Icons.auto_stories,
        'unlocked': false,
      },
      {
        'name': 'Pecinta Seni',
        'desc': 'Scan 10 QR lokasi',
        'icon': Icons.qr_code_scanner,
        'unlocked': false,
      },
      {
        'name': 'Legenda Nusantara',
        'desc': 'Koleksi lengkap artifact',
        'icon': Icons.emoji_events,
        'unlocked': false,
      },
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
              // Mascot Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.pink.shade300],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getMascotIcon(),
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<ProfileProvider>(
                      builder: (context, profileProvider, _) {
                        return Text(
                          profileProvider.profile?.mascot ?? mascot,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pemandu Budayamu',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),

                    // XP Progress Bar
                    Consumer<HomeProvider>(
                      builder: (context, homeProvider, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Level ${homeProvider.userLevel}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${homeProvider.userXP}/${homeProvider.xpForNextLevel} XP',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: homeProvider.progressToNextLevel,
                                minHeight: 12,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Koleksi Artifact
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Koleksi Artifact',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '2/5',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: artifacts.length,
                  itemBuilder: (context, index) {
                    final artifact = artifacts[index];
                    final isLocked = artifact['locked'] as bool;

                    return Container(
                      width: 110,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color:
                            isLocked
                                ? Colors.grey.shade200
                                : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isLocked
                                  ? Colors.grey.shade300
                                  : Colors.orange.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                artifact['icon'] as IconData,
                                color:
                                    isLocked
                                        ? Colors.grey.shade400
                                        : Colors.orange.shade700,
                                size: 48,
                              ),
                              if (isLocked)
                                Icon(
                                  Icons.lock,
                                  color: Colors.grey.shade600,
                                  size: 24,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              artifact['name'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color:
                                    isLocked
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade800,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Achievements
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pencapaian',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  final unlocked = achievement['unlocked'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          unlocked
                              ? Colors.amber.shade50
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            unlocked
                                ? Colors.amber.shade300
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                unlocked
                                    ? Colors.amber.shade100
                                    : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            achievement['icon'] as IconData,
                            color:
                                unlocked
                                    ? Colors.amber.shade700
                                    : Colors.grey.shade500,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement['name'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      unlocked
                                          ? Colors.grey.shade900
                                          : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                achievement['desc'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      unlocked
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (unlocked)
                          Icon(
                            Icons.check_circle,
                            color: Colors.amber.shade700,
                            size: 28,
                          )
                        else
                          Icon(
                            Icons.lock,
                            color: Colors.grey.shade400,
                            size: 24,
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
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Apakah kamu yakin ingin keluar?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                    );

                    if (shouldLogout == true && context.mounted) {
                      // Get all providers
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final profileProvider = Provider.of<ProfileProvider>(
                        context,
                        listen: false,
                      );
                      final homeProvider = Provider.of<HomeProvider>(
                        context,
                        listen: false,
                      );

                      // Clear all state
                      profileProvider.clear();
                      homeProvider.resetProgress();

                      // Sign out
                      await authProvider.signOut();

                      // FORCE navigate to login screen
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    }
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
}
