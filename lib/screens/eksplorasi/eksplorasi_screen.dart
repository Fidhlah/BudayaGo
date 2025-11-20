import 'package:flutter/material.dart';
import 'category_detail_screen.dart';

class EksplorasiScreen extends StatelessWidget {
  const EksplorasiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Pakaian Adat', 'icon': Icons.checkroom, 'color': Colors.purple},
      {'name': 'Tarian', 'icon': Icons.music_note, 'color': Colors.pink},
      {'name': 'Makanan', 'icon': Icons.restaurant, 'color': Colors.orange},
      {'name': 'Rumah Adat', 'icon': Icons.home, 'color': Colors.teal},
      {'name': 'Alat Musik', 'icon': Icons.piano, 'color': Colors.indigo},
      {'name': 'Cerita Rakyat', 'icon': Icons.menu_book, 'color': Colors.brown},
      {
        'name': 'Senjata Tradisional',
        'icon': Icons.loyalty,
        'color': Colors.red,
      },
      {
        'name': 'Upacara Adat',
        'icon': Icons.celebration,
        'color': Colors.deepPurple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksplorasi Pengetahuan'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CategoryDetailScreen(
                          categoryName: category['name'] as String,
                          categoryColor: category['color'] as Color,
                          categoryIcon: category['icon'] as IconData,
                        ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        size: 40,
                        color: category['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category['name'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
