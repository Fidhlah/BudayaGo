import 'package:flutter/material.dart';

class UmkmDetailScreen extends StatelessWidget {
  final String umkmName;
  final String category;
  final Color accentColor;

  const UmkmDetailScreen({
    Key? key,
    required this.umkmName,
    required this.category,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan foto
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: accentColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                umkmName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background sebagai placeholder foto
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [accentColor, accentColor.withOpacity(0.6)],
                      ),
                    ),
                  ),
                  // Icon overlay
                  Center(
                    child: Icon(
                      _getIcon(umkmName),
                      size: 100,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    bottom: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tentang ${umkmName.split(' ')[0]}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getDescription(umkmName),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),

                  // Info tambahan
                  _buildInfoCard(
                    'Lokasi',
                    _getLocation(umkmName),
                    Icons.location_on,
                    accentColor,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Tahun Berdiri',
                    _getYear(umkmName),
                    Icons.calendar_today,
                    accentColor,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Jumlah Pengrajin',
                    _getCraftsmen(umkmName),
                    Icons.people,
                    accentColor,
                  ),
                ],
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String umkm) {
    switch (umkm) {
      case 'Batik Nusantara':
        return Icons.auto_awesome;
      case 'Kerajinan Kayu':
        return Icons.chair;
      case 'Gerabah Tradisional':
        return Icons.local_florist;
      case 'Anyaman Bambu':
        return Icons.shopping_basket;
      case 'Tenun Ikat':
        return Icons.texture;
      case 'Wayang Kulit':
        return Icons.theater_comedy;
      default:
        return Icons.diamond;
    }
  }

  String _getLocation(String umkm) {
    switch (umkm) {
      case 'Batik Nusantara':
        return 'Solo, Jawa Tengah';
      case 'Kerajinan Kayu':
        return 'Jepara, Jawa Tengah';
      case 'Gerabah Tradisional':
        return 'Kasongan, Yogyakarta';
      case 'Anyaman Bambu':
        return 'Tasikmalaya, Jawa Barat';
      case 'Tenun Ikat':
        return 'Flores, Nusa Tenggara Timur';
      case 'Wayang Kulit':
        return 'Solo, Jawa Tengah';
      default:
        return 'Indonesia';
    }
  }

  String _getYear(String umkm) {
    switch (umkm) {
      case 'Batik Nusantara':
        return '1985';
      case 'Kerajinan Kayu':
        return '1978';
      case 'Gerabah Tradisional':
        return '1992';
      case 'Anyaman Bambu':
        return '1988';
      case 'Tenun Ikat':
        return '1995';
      case 'Wayang Kulit':
        return '1980';
      default:
        return '1990';
    }
  }

  String _getCraftsmen(String umkm) {
    switch (umkm) {
      case 'Batik Nusantara':
        return '45 Pengrajin';
      case 'Kerajinan Kayu':
        return '32 Pengrajin';
      case 'Gerabah Tradisional':
        return '28 Pengrajin';
      case 'Anyaman Bambu':
        return '38 Pengrajin';
      case 'Tenun Ikat':
        return '52 Pengrajin';
      case 'Wayang Kulit':
        return '15 Pengrajin';
      default:
        return '20 Pengrajin';
    }
  }

  String _getDescription(String umkm) {
    switch (umkm) {
      case 'Batik Nusantara':
        return 'Batik adalah warisan budaya Indonesia yang diakui UNESCO. Setiap motif memiliki filosofi dan makna mendalam yang mencerminkan kearifan lokal. Kami memproduksi batik dengan teknik tulis dan cap tradisional, menggunakan pewarna alami dari tumbuhan. Setiap helai kain adalah karya seni yang dibuat dengan penuh dedikasi oleh para pengrajin berpengalaman.';
      case 'Kerajinan Kayu':
        return 'Kerajinan kayu ukir Jepara terkenal hingga mancanegara dengan detail dan kehalusannya. Menggunakan kayu jati dan mahoni berkualitas tinggi, setiap produk dikerjakan oleh tangan-tangan terampil pengrajin yang mewarisi keahlian turun-temurun. Dari furniture hingga hiasan dinding, setiap karya menampilkan keindahan dan kekokohan khas Indonesia.';
      case 'Gerabah Tradisional':
        return 'Gerabah Kasongan adalah hasil karya pengrajin yang telah diwariskan secara turun-temurun. Dibuat dari tanah liat pilihan dan dibakar dengan teknik tradisional, menghasilkan produk yang kuat dan artistik. Setiap bentuk memiliki keunikan tersendiri, dari guci hias hingga peralatan dapur yang ramah lingkungan.';
      case 'Anyaman Bambu':
        return 'Anyaman bambu adalah seni merajut bambu menjadi berbagai produk fungsional dan dekoratif. Bambu yang fleksibel dan kuat dianyam dengan pola-pola tradisional yang rumit. Produk kami ramah lingkungan, tahan lama, dan memiliki nilai estetika tinggi. Dari tas hingga furniture, semuanya hand-made dengan penuh ketelitian.';
      case 'Tenun Ikat':
        return 'Tenun ikat adalah teknik pewarnaan dan penenunan benang yang menghasilkan motif unik khas Nusantara. Setiap daerah memiliki corak khas yang mencerminkan budaya setempat. Proses pembuatan yang panjang dan rumit menghasilkan kain berkualitas tinggi dengan motif yang tidak akan pudar. Setiap helai kain adalah masterpiece yang bernilai tinggi.';
      case 'Wayang Kulit':
        return 'Wayang kulit adalah seni pertunjukan tradisional yang menggunakan boneka kulit kerbau yang diukir dan diwarnai dengan indah. Setiap karakter memiliki bentuk dan filosofi yang mendalam. Kami membuat wayang dengan teknik tradisional, dari proses pemilihan kulit hingga pewarnaan detail. Wayang kami tidak hanya untuk pertunjukan, tetapi juga sebagai koleksi seni bernilai tinggi.';
      default:
        return 'Produk kerajinan berkualitas tinggi yang dibuat dengan penuh dedikasi oleh pengrajin Indonesia.';
    }
  }
}
