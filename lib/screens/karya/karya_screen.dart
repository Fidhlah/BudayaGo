import 'package:flutter/material.dart';

class KaryaScreen extends StatelessWidget {
  const KaryaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data UMKM
    final umkmList = [
      {
        'name': 'Batik Nusantara',
        'category': 'Kain & Tekstil',
        'icon': Icons.checkroom,
        'color': Colors.blue,
      },
      {
        'name': 'Kerajinan Kayu',
        'category': 'Furniture & Dekorasi',
        'icon': Icons.chair,
        'color': Colors.brown,
      },
      {
        'name': 'Gerabah Tradisional',
        'category': 'Keramik & Tembikar',
        'icon': Icons.local_florist,
        'color': Colors.orange,
      },
      {
        'name': 'Anyaman Bambu',
        'category': 'Kerajinan Tangan',
        'icon': Icons.shopping_basket,
        'color': Colors.green,
      },
      {
        'name': 'Tenun Ikat',
        'category': 'Kain & Tekstil',
        'icon': Icons.texture,
        'color': Colors.purple,
      },
      {
        'name': 'Wayang Kulit',
        'category': 'Seni & Budaya',
        'icon': Icons.theater_comedy,
        'color': Colors.red,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karya Pelaku Budaya'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: umkmList.length,
        itemBuilder: (context, index) {
          final umkm = umkmList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${umkm['name']} - Coming Soon!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: (umkm['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        umkm['icon'] as IconData,
                        size: 35,
                        color: umkm['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            umkm['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            umkm['category'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
