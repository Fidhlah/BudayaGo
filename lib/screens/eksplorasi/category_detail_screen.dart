import 'package:flutter/material.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryDetailScreen({
    Key? key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = _getCategoryItems(categoryName);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: categoryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                categoryName,
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
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [categoryColor, categoryColor.withOpacity(0.7)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    categoryIcon,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to item detail
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Detail ${item['name']} - Coming Soon!',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  categoryColor.withOpacity(0.3),
                                  categoryColor.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Icon(
                              categoryIcon,
                              size: 80,
                              color: categoryColor.withOpacity(0.5),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['region'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item['description'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.orange.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item['xp']} XP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: items.length),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCategoryItems(String category) {
    switch (category) {
      case 'Pakaian Adat':
        return [
          {
            'name': 'Kebaya',
            'region': 'Jawa',
            'description':
                'Kebaya adalah pakaian tradisional Indonesia yang elegan, dikenakan oleh wanita dengan kain batik atau sarung. Melambangkan keanggunan dan kesopanan dalam budaya Jawa.',
            'xp': 15,
          },
          {
            'name': 'Ulos',
            'region': 'Sumatera Utara (Batak)',
            'description':
                'Ulos adalah kain tenun tradisional Batak yang memiliki makna filosofis mendalam. Digunakan dalam upacara adat dan melambangkan kehangatan, kasih sayang, dan berkah.',
            'xp': 20,
          },
          {
            'name': 'Baju Bodo',
            'region': 'Sulawesi Selatan (Bugis-Makassar)',
            'description':
                'Pakaian tradisional wanita Bugis-Makassar yang terkenal dengan kesederhanaannya. Warna baju bodo menunjukkan status sosial pemakainya dalam masyarakat.',
            'xp': 15,
          },
          {
            'name': 'Payas Agung',
            'region': 'Bali',
            'description':
                'Pakaian adat Bali yang dikenakan dalam upacara keagamaan penting. Sangat megah dengan hiasan emas dan kain songket yang indah.',
            'xp': 25,
          },
        ];

      case 'Tarian':
        return [
          {
            'name': 'Tari Saman',
            'region': 'Aceh',
            'description':
                'Tarian massal yang terkenal dengan gerakan kompak dan pukulan dada yang dinamis. UNESCO mengakui sebagai Warisan Budaya Tak Benda. Biasanya dibawakan oleh puluhan penari pria.',
            'xp': 25,
          },
          {
            'name': 'Tari Kecak',
            'region': 'Bali',
            'description':
                'Tarian ritual yang unik tanpa iringan musik, hanya suara "cak" dari puluhan penari pria. Menceritakan kisah Ramayana dengan gerakan ekspresif.',
            'xp': 20,
          },
          {
            'name': 'Tari Piring',
            'region': 'Sumatera Barat (Minangkabau)',
            'description':
                'Tarian dengan menggunakan piring di telapak tangan. Gerakan cepat dan lincah melambangkan rasa syukur atas hasil panen yang melimpah.',
            'xp': 20,
          },
          {
            'name': 'Tari Pendet',
            'region': 'Bali',
            'description':
                'Tarian penyambutan yang indah dan anggun. Awalnya tarian sakral di pura, kini menjadi tarian penyambutan tamu kehormatan.',
            'xp': 15,
          },
          {
            'name': 'Tari Jaipong',
            'region': 'Jawa Barat (Sunda)',
            'description':
                'Tarian modern yang menggabungkan unsur tradisional dengan dinamika kontemporer. Gerakan energik dan ekspresif yang memukau.',
            'xp': 18,
          },
        ];

      case 'Makanan':
        return [
          {
            'name': 'Rendang',
            'region': 'Sumatera Barat (Minangkabau)',
            'description':
                'Masakan daging dengan bumbu rempah yang kaya, dimasak berjam-jam hingga bumbu meresap sempurna. Dinobatkan sebagai makanan terenak di dunia oleh CNN.',
            'xp': 25,
          },
          {
            'name': 'Gudeg',
            'region': 'Yogyakarta',
            'description':
                'Nangka muda yang dimasak dengan santan dan gula merah hingga berwarna cokelat. Disajikan dengan ayam, telur, dan sambal krecek.',
            'xp': 20,
          },
          {
            'name': 'Pempek',
            'region': 'Palembang, Sumatera Selatan',
            'description':
                'Makanan dari ikan dan sagu yang disajikan dengan kuah cuka pedas (cuko). Ada berbagai jenis seperti kapal selam, lenjer, dan adaan.',
            'xp': 18,
          },
          {
            'name': 'Sate',
            'region': 'Berbagai Daerah',
            'description':
                'Daging tusuk yang dipanggang dengan bumbu kacang atau kecap. Setiap daerah punya variasi unik seperti sate Madura, Padang, dan Lilit Bali.',
            'xp': 15,
          },
          {
            'name': 'Rawon',
            'region': 'Jawa Timur',
            'description':
                'Sup daging berwarna hitam dari kluwak dengan rasa gurih yang khas. Disajikan dengan nasi, tauge, telur asin, dan sambal.',
            'xp': 20,
          },
        ];

      case 'Rumah Adat':
        return [
          {
            'name': 'Rumah Gadang',
            'region': 'Sumatera Barat (Minangkabau)',
            'description':
                'Rumah dengan atap berbentuk tanduk kerbau yang melengkung. Mencerminkan filosofi matrilineal masyarakat Minang dan keindahan arsitektur tradisional.',
            'xp': 25,
          },
          {
            'name': 'Tongkonan',
            'region': 'Sulawesi Selatan (Toraja)',
            'description':
                'Rumah adat dengan atap melengkung menyerupai perahu. Dihiasi ukiran penuh makna dan digunakan untuk upacara adat penting.',
            'xp': 25,
          },
          {
            'name': 'Joglo',
            'region': 'Jawa Tengah',
            'description':
                'Rumah dengan struktur atap unik bertumpuk empat. Menunjukkan status sosial tinggi dan filosofi kehidupan Jawa yang harmonis.',
            'xp': 20,
          },
          {
            'name': 'Honai',
            'region': 'Papua',
            'description':
                'Rumah bulat dari kayu dan jerami untuk melindungi dari dingin pegunungan Papua. Ruangan kecil untuk menjaga kehangatan tubuh.',
            'xp': 22,
          },
        ];

      case 'Alat Musik':
        return [
          {
            'name': 'Gamelan',
            'region': 'Jawa & Bali',
            'description':
                'Seperangkat alat musik tradisional yang dimainkan bersama. Terdiri dari gong, kendang, saron, dan bonang dengan harmoni yang indah.',
            'xp': 25,
          },
          {
            'name': 'Angklung',
            'region': 'Jawa Barat (Sunda)',
            'description':
                'Alat musik dari bambu yang digoyangkan. Diakui UNESCO sebagai Warisan Budaya Tak Benda. Menghasilkan nada merdu dan harmonis.',
            'xp': 20,
          },
          {
            'name': 'Sasando',
            'region': 'Nusa Tenggara Timur (Rote)',
            'description':
                'Alat musik petik dari daun lontar dengan suara lembut dan merdu. Bentuknya unik seperti harpa tradisional.',
            'xp': 22,
          },
          {
            'name': 'Kolintang',
            'region': 'Sulawesi Utara (Minahasa)',
            'description':
                'Alat musik perkusi dari kayu dengan nada-nada berbeda. Dimainkan dengan cara dipukul menggunakan stik kayu.',
            'xp': 18,
          },
          {
            'name': 'Tifa',
            'region': 'Papua & Maluku',
            'description':
                'Gendang tradisional berbentuk tabung dari kayu. Dimainkan dalam upacara adat dan tarian perang tradisional.',
            'xp': 15,
          },
        ];

      case 'Cerita Rakyat':
        return [
          {
            'name': 'Malin Kundang',
            'region': 'Sumatera Barat',
            'description':
                'Kisah anak durhaka yang dikutuk menjadi batu karena menyangkal ibunya. Mengajarkan pentingnya berbakti kepada orang tua.',
            'xp': 15,
          },
          {
            'name': 'Sangkuriang',
            'region': 'Jawa Barat',
            'description':
                'Legenda asal mula Gunung Tangkuban Perahu dan Danau Bandung. Kisah cinta terlarang antara ibu dan anak yang tragis.',
            'xp': 18,
          },
          {
            'name': 'Timun Mas',
            'region': 'Jawa Tengah',
            'description':
                'Gadis pemberani yang kabur dari raksasa Buto Ijo menggunakan benda-benda ajaib. Mengajarkan keberanian dan kecerdikan.',
            'xp': 15,
          },
          {
            'name': 'Bawang Merah Bawang Putih',
            'region': 'Berbagai Daerah',
            'description':
                'Kisah dua saudara tiri dengan sifat berbeda. Kebaikan Bawang Putih dibalas dengan kebahagiaan, sementara kejahatan Bawang Merah mendapat balasan setimpal.',
            'xp': 15,
          },
          {
            'name': 'Legenda Danau Toba',
            'region': 'Sumatera Utara',
            'description':
                'Asal mula Danau Toba dan Pulau Samosir dari seorang pemuda yang melanggar janji pada istri ikannya. Air bah menenggelamkan kampung.',
            'xp': 20,
          },
        ];

      case 'Senjata Tradisional':
        return [
          {
            'name': 'Keris',
            'region': 'Jawa',
            'description':
                'Senjata tikam dengan lekukan berliku yang dianggap sakral. Memiliki filosofi mendalam dan sering dianggap pusaka keluarga.',
            'xp': 25,
          },
          {
            'name': 'Mandau',
            'region': 'Kalimantan (Dayak)',
            'description':
                'Pedang khas Dayak dengan sarung dari kayu dan dihiasi bulu burung enggang. Digunakan dalam ritual dan pertempuran.',
            'xp': 22,
          },
          {
            'name': 'Rencong',
            'region': 'Aceh',
            'description':
                'Senjata tikam melengkung berbentuk huruf L. Melambangkan keberanian dan kehormatan kesatria Aceh.',
            'xp': 20,
          },
          {
            'name': 'Badik',
            'region': 'Sulawesi Selatan',
            'description':
                'Belati khas Bugis-Makassar dengan gagang dari tanduk atau kayu. Simbol keberanian dan kehormatan laki-laki Bugis.',
            'xp': 18,
          },
        ];

      case 'Upacara Adat':
        return [
          {
            'name': 'Ngaben',
            'region': 'Bali',
            'description':
                'Upacara kremasi jenazah untuk membebaskan roh dari ikatan duniawi. Prosesi megah dengan bade (wadah jenazah) yang indah.',
            'xp': 25,
          },
          {
            'name': 'Rambu Solo',
            'region': 'Sulawesi Selatan (Toraja)',
            'description':
                'Upacara pemakaman dengan ritual kompleks yang berlangsung berhari-hari. Melibatkan seluruh keluarga dan masyarakat.',
            'xp': 25,
          },
          {
            'name': 'Sekaten',
            'region': 'Yogyakarta & Surakarta',
            'description':
                'Upacara memperingati Maulid Nabi Muhammad dengan gamelan pusaka keraton. Pasar malam tradisional dengan berbagai wahana.',
            'xp': 20,
          },
          {
            'name': 'Tabuik',
            'region': 'Sumatera Barat (Pariaman)',
            'description':
                'Upacara memperingati gugurnya cucu Nabi Muhammad dengan replika makam yang megah. Diarak ke laut dalam prosesi khidmat.',
            'xp': 22,
          },
          {
            'name': 'Kasada',
            'region': 'Jawa Timur (Tengger)',
            'description':
                'Upacara persembahan hasil bumi ke kawah Gunung Bromo. Masyarakat Tengger melempar sesaji sebagai ungkapan syukur.',
            'xp': 23,
          },
        ];

      default:
        return [];
    }
  }
}
