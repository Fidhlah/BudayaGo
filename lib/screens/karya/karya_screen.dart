import 'package:flutter/material.dart';
import 'umkm_detail_screen.dart';

class KaryaScreen extends StatefulWidget {
  const KaryaScreen({Key? key}) : super(key: key);

  @override
  State<KaryaScreen> createState() => _KaryaScreenState();
}

class _KaryaScreenState extends State<KaryaScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock data karya dengan variasi ukuran
    final karyaItems = [
      {
        'name': 'Batik Tulis Parang',
        'creator': 'Ibu Siti - Solo',
        'tag': 'Batik',
        'umkm': 'Batik Nusantara',
        'color': Colors.blue.shade300,
        'height': 200.0,
        'icon': Icons.auto_awesome,
      },
      {
        'name': 'Meja Kayu Jati Ukir',
        'creator': 'Pak Budi - Jepara',
        'tag': 'Furniture',
        'umkm': 'Kerajinan Kayu',
        'color': Colors.brown.shade300,
        'height': 280.0,
        'icon': Icons.table_restaurant,
      },
      {
        'name': 'Guci Kasongan',
        'creator': 'Pak Wawan - Yogyakarta',
        'tag': 'Keramik',
        'umkm': 'Gerabah Tradisional',
        'color': Colors.orange.shade300,
        'height': 160.0,
        'icon': Icons.local_florist,
      },
      {
        'name': 'Tas Anyaman Premium',
        'creator': 'Ibu Ani - Tasikmalaya',
        'tag': 'Anyaman',
        'umkm': 'Anyaman Bambu',
        'color': Colors.green.shade300,
        'height': 220.0,
        'icon': Icons.shopping_bag,
      },
      {
        'name': 'Kain Tenun Flores',
        'creator': 'Ibu Maria - NTT',
        'tag': 'Tenun',
        'umkm': 'Tenun Ikat',
        'color': Colors.purple.shade300,
        'height': 190.0,
        'icon': Icons.texture,
      },
      {
        'name': 'Wayang Arjuna',
        'creator': 'Pak Dalang - Solo',
        'tag': 'Wayang',
        'umkm': 'Wayang Kulit',
        'color': Colors.red.shade300,
        'height': 240.0,
        'icon': Icons.person,
      },
      {
        'name': 'Batik Cap Kawung',
        'creator': 'Ibu Ratna - Pekalongan',
        'tag': 'Batik',
        'umkm': 'Batik Nusantara',
        'color': Colors.indigo.shade300,
        'height': 170.0,
        'icon': Icons.auto_awesome,
      },
      {
        'name': 'Kursi Tamu Ukir',
        'creator': 'Pak Joko - Jepara',
        'tag': 'Furniture',
        'umkm': 'Kerajinan Kayu',
        'color': Colors.brown.shade400,
        'height': 210.0,
        'icon': Icons.chair,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karya Pelaku Budaya'),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.orange.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari karya, pelaku, atau tag...',
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.orange),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Content
          Expanded(
            child:
                _getFilteredItems(karyaItems).isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada karya yang ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba kata kunci lain',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildMasonryLayout(
                          context,
                          _getFilteredItems(karyaItems),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredItems(
    List<Map<String, dynamic>> items,
  ) {
    if (_searchQuery.isEmpty) {
      return items;
    }

    return items.where((item) {
      final name = (item['name'] as String).toLowerCase();
      final creator = (item['creator'] as String).toLowerCase();
      final tag = (item['tag'] as String).toLowerCase();
      final umkm = (item['umkm'] as String).toLowerCase();

      return name.contains(_searchQuery) ||
          creator.contains(_searchQuery) ||
          tag.contains(_searchQuery) ||
          umkm.contains(_searchQuery);
    }).toList();
  }

  Widget _buildMasonryLayout(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    // Split items into 2 columns
    final leftColumn = <Map<String, dynamic>>[];
    final rightColumn = <Map<String, dynamic>>[];

    for (int i = 0; i < items.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(items[i]);
      } else {
        rightColumn.add(items[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children:
                leftColumn
                    .map((item) => _buildKaryaCard(context, item))
                    .toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children:
                rightColumn
                    .map((item) => _buildKaryaCard(context, item))
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKaryaCard(BuildContext context, Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate ke detail screen UMKM
          final umkmName = item['umkm'] as String;
          Color accentColor;
          String category;

          // Map ke data UMKM yang sesuai
          switch (umkmName) {
            case 'Batik Nusantara':
              accentColor = Colors.blue;
              category = 'Kain & Tekstil';
              break;
            case 'Kerajinan Kayu':
              accentColor = Colors.brown;
              category = 'Furniture & Dekorasi';
              break;
            case 'Gerabah Tradisional':
              accentColor = Colors.orange;
              category = 'Keramik & Tembikar';
              break;
            case 'Anyaman Bambu':
              accentColor = Colors.green;
              category = 'Kerajinan Tangan';
              break;
            case 'Tenun Ikat':
              accentColor = Colors.purple;
              category = 'Kain & Tekstil';
              break;
            case 'Wayang Kulit':
              accentColor = Colors.red;
              category = 'Seni & Budaya';
              break;
            default:
              accentColor = Colors.grey;
              category = 'Kerajinan';
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => UmkmDetailScreen(
                    umkmName: umkmName,
                    category: category,
                    accentColor: accentColor,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with gradient
            Container(
              height: item['height'] as double,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (item['color'] as Color).withOpacity(0.8),
                    (item['color'] as Color).withOpacity(0.4),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative icon
                  Center(
                    child: Icon(
                      item['icon'] as IconData,
                      size: 60,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  // Tag at bottom
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['tag'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: item['color'] as Color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['creator'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
