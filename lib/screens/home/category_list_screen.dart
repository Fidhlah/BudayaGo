import 'package:flutter/material.dart';
import 'detail_item_screen.dart';
import '../../widgets/custom_app_bar.dart';

class CategoryListScreen extends StatelessWidget {
  final String category;
  final Function(int) onXPGained;

  const CategoryListScreen({
    Key? key,
    required this.category,
    required this.onXPGained,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = _getItemsForCategory(category);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: CustomGradientAppBar(title: category),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DetailItemScreen(
                            item: item,
                            onXPGained: onXPGained,
                          ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange.shade200, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 40,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['origin'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${item['xp']} XP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getItemsForCategory(String category) {
    switch (category) {
      case 'Pakaian Adat':
        return [
          {
            'name': 'Kebaya',
            'origin': 'Jawa',
            'icon': Icons.checkroom,
            'xp': 15,
            'description':
                'Kebaya adalah pakaian tradisional wanita Indonesia yang berasal dari Jawa. Kebaya memiliki potongan yang anggun dengan bahan yang tipis dan transparan, biasanya dipadukan dengan kain batik atau songket sebagai bawahannya.\n\nKebaya telah menjadi simbol keanggunan wanita Indonesia dan dikenakan dalam berbagai acara resmi dan perayaan. Setiap daerah memiliki variasi kebaya dengan ciri khas masing-masing, seperti Kebaya Encim dari Betawi, Kebaya Kartini dari Jawa Tengah, dan Kebaya Bali yang lebih berwarna cerah.',
          },
          {
            'name': 'Baju Bodo',
            'origin': 'Sulawesi Selatan',
            'icon': Icons.checkroom,
            'xp': 15,
            'description':
                'Baju Bodo adalah pakaian adat tradisional perempuan Bugis dan Makassar dari Sulawesi Selatan. Baju ini terkenal dengan bentuknya yang sederhana dan warnanya yang beragam.\n\nSetiap warna Baju Bodo memiliki makna dan menunjukkan status pemakainya. Misalnya, warna jingga untuk putri raja, merah untuk pemerintah, putih untuk pemuka agama, dan hijau untuk bangsawan. Baju Bodo adalah salah satu pakaian tradisional tertua di Indonesia.',
          },
          {
            'name': 'Ulos',
            'origin': 'Sumatera Utara',
            'icon': Icons.checkroom,
            'xp': 15,
            'description':
                'Ulos adalah kain tenun tradisional Batak dari Sumatera Utara. Ulos memiliki nilai filosofis yang sangat dalam dalam budaya Batak dan dianggap sebagai simbol kasih sayang, kehangatan, dan penghormatan.\n\nUlos diberikan dalam berbagai upacara adat seperti pernikahan, kelahiran, dan kematian. Setiap motif Ulos memiliki makna dan kegunaan yang berbeda-beda dalam adat Batak.',
          },
        ];
      case 'Tarian':
        return [
          {
            'name': 'Tari Saman',
            'origin': 'Aceh',
            'icon': Icons.music_note,
            'xp': 20,
            'description':
                'Tari Saman adalah tarian tradisional dari Aceh yang terkenal dengan gerakannya yang kompak dan dinamis. Tarian ini ditarikan oleh puluhan penari pria yang duduk berbaris sambil melakukan gerakan tepuk tangan, goyangan badan, dan nyanyian.\n\nTari Saman telah diakui UNESCO sebagai Warisan Budaya Takbenda pada tahun 2011. Tarian ini biasanya ditampilkan dalam acara-acara besar dan membutuhkan kekompakan yang tinggi antar penari.',
          },
          {
            'name': 'Tari Pendet',
            'origin': 'Bali',
            'icon': Icons.music_note,
            'xp': 20,
            'description':
                'Tari Pendet adalah tarian tradisional Bali yang awalnya merupakan tarian pemujaan di pura. Tarian ini ditarikan oleh penari wanita dengan gerakan yang lembut dan anggun sambil membawa bokor berisi bunga.\n\nTari Pendet melambangkan penyambutan turunnya dewata ke dunia dan merupakan ungkapan rasa syukur kepada Sang Hyang Widhi.',
          },
        ];
      case 'Makanan':
        return [
          {
            'name': 'Rendang',
            'origin': 'Sumatera Barat',
            'icon': Icons.restaurant,
            'xp': 15,
            'description':
                'Rendang adalah masakan daging dengan bumbu rempah-rempah dari Minangkabau, Sumatera Barat. CNN pernah menobatkan Rendang sebagai makanan terenak di dunia.\n\nProses memasak rendang memakan waktu berjam-jam dengan api kecil hingga bumbu meresap dan daging menjadi empuk. Rendang biasanya disajikan dalam acara-acara adat dan perayaan istimewa.',
          },
          {
            'name': 'Gudeg',
            'origin': 'Yogyakarta',
            'icon': Icons.restaurant,
            'xp': 15,
            'description':
                'Gudeg adalah makanan khas Yogyakarta yang terbuat dari nangka muda yang dimasak dengan santan dan gula kelapa hingga berwarna cokelat. Gudeg biasanya disajikan dengan nasi, ayam, telur, tahu, tempe, dan sambal goreng krecek.\n\nProses memasak gudeg memakan waktu lama, kadang hingga semalam, untuk mendapatkan cita rasa yang sempurna.',
          },
        ];
      default:
        return [];
    }
  }
}
