import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/app_colors.dart';
import 'cultural_object_detail_screen.dart';

class CulturalObjectsScreen extends StatelessWidget {
  final String categoryName;
  final String categoryId;
  final Color categoryColor;
  final IconData categoryIcon;

  const CulturalObjectsScreen({
    Key? key,
    required this.categoryName,
    required this.categoryId,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  double _getCardHeight(int index) {
    // Pattern tinggi yang bervariasi seperti referensi
    final heights = [180.0, 150.0, 200.0, 160.0, 170.0, 190.0];
    return heights[index % heights.length];
  }

  @override
  Widget build(BuildContext context) {
    final objects = _getCulturalObjects(categoryName);

    return Scaffold(
      backgroundColor: AppColors.orange50,
      appBar: CustomGradientAppBar(title: categoryName, showBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildMasonryLayout(context, objects),
        ),
      ),
    );
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
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildMasonryCard(
                        context,
                        entry.value,
                        entry.key * 2,
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children:
                rightColumn
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildMasonryCard(
                        context,
                        entry.value,
                        entry.key * 2 + 1,
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMasonryCard(
    BuildContext context,
    Map<String, dynamic> object,
    int index,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CulturalObjectDetailScreen(
                  objectName: object['name'],
                  region: object['region'],
                  description: object['description'],
                  fullContent: object['fullContent'],
                  xp: object['xp'],
                  categoryColor: categoryColor,
                  categoryIcon: categoryIcon,
                  imageUrl: object['imageUrl'],
                ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Container(
                height: _getCardHeight(index),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withOpacity(0.3),
                      categoryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  categoryIcon,
                  size: 50,
                  color: categoryColor.withOpacity(0.5),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    object['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    object['region'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.orange.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${object['xp']} XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
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
  }

  // Bagian _getCulturalObjects() tidak diubah
  List<Map<String, dynamic>> _getCulturalObjects(String category) {
    // Data dummy - nanti bisa diganti dengan data dari database
    switch (category) {
      case 'Olahraga Tradisional':
        return [
          // ... (isi data seperti semula)
          {
            'name': 'Pencak Silat',
            'region': 'Indonesia',
            'description': 'Seni bela diri tradisional Indonesia',
            'xp': 25,
            'imageUrl': null,
            'fullContent': '''
# Pencak Silat

## Sejarah
Pencak Silat adalah seni bela diri tradisional yang berasal dari Indonesia dan telah berkembang sejak abad ke-7. Seni bela diri ini tidak hanya merupakan teknik pertahanan diri, tetapi juga mencerminkan nilai-nilai budaya, spiritual, dan filosofi masyarakat Indonesia.

## Karakteristik
Pencak Silat memiliki gerakan yang sangat beragam, menggabungkan unsur serangan, tangkisan, kuncian, dan lemparan. Setiap daerah di Indonesia memiliki aliran Pencak Silat yang berbeda dengan ciri khas masing-masing.

### Unsur-unsur Pencak Silat:
- **Aspek Mental-Spiritual**: Pembentukan karakter dan kepribadian
- **Aspek Seni Budaya**: Keindahan gerakan dan iringan musik
- **Aspek Bela Diri**: Teknik pertahanan dan serangan
- **Aspek Olahraga**: Kompetisi dan prestasi

## Aliran Terkenal
1. **Cimande** (Jawa Barat)
2. **Cikalong** (Jawa Barat)
3. **Minangkabau** (Sumatera Barat)
4. **Betawi** (Jakarta)

## Pengakuan Dunia
UNESCO telah mengakui Pencak Silat sebagai Warisan Budaya Tak Benda pada tahun 2019. Saat ini, Pencak Silat telah berkembang dan dipraktikkan di lebih dari 50 negara di seluruh dunia.

## Kompetisi
Pencak Silat dipertandingkan dalam berbagai event olahraga regional seperti SEA Games, Asian Games, dan memiliki kejuaraan dunia tersendiri.
''',
          },
          {
            'name': 'Karapan Sapi',
            'region': 'Madura, Jawa Timur',
            'description': 'Perlombaan pacuan sapi tradisional Madura',
            'xp': 20,
            'imageUrl': null,
            'fullContent': '''
# Karapan Sapi

## Asal Usul
Karapan Sapi adalah tradisi balap sapi yang berasal dari Pulau Madura, Jawa Timur. Tradisi ini sudah ada sejak abad ke-14 dan menjadi identitas budaya masyarakat Madura.

## Cara Bermain
Dalam perlombaan ini, sepasang sapi yang telah dilatih khusus akan ditunggangi oleh joki yang berdiri di atas papan kayu sederhana (galesong). Sapi-sapi tersebut akan berlari kencang menempuh lintasan sepanjang 100-120 meter.

## Persiapan
Sapi yang akan diikutsertakan dalam karapan harus dilatih secara khusus selama berbulan-bulan. Pemilik sapi memberikan perawatan istimewa, termasuk:
- Pakan berkualitas tinggi
- Latihan rutin
- Pijat dan perawatan tubuh
- Jamu tradisional untuk stamina

## Hiburan Rakyat
Karapan Sapi bukan hanya sekedar perlombaan, tetapi juga menjadi ajang hiburan rakyat yang meriah dengan:
- Musik patrol dan saronen
- Dekorasi sapi yang indah
- Antusiasme penonton yang luar biasa
- Kebanggaan pemilik sapi

## Makna Budaya
Bagi masyarakat Madura, Karapan Sapi merupakan simbol kejantanan, keberanian, dan prestise. Pemilik sapi juara akan mendapat kehormatan tinggi di masyarakat.
''',
          },
          {
            'name': 'Egrang',
            'region': 'Berbagai Daerah',
            'description': 'Permainan berjalan di atas tongkat bambu',
            'xp': 15,
            'imageUrl': null,
            'fullContent': '''
# Egrang

## Pengenalan
Egrang adalah permainan tradisional yang menggunakan dua tongkat bambu atau kayu dengan pijakan kaki. Pemain harus berjalan atau berlari di atas tongkat tersebut sambil menjaga keseimbangan.

## Sejarah
Egrang telah dimainkan di berbagai wilayah Indonesia sejak zaman dahulu. Beberapa sumber menyebutkan permainan ini berasal dari keperluan praktis masyarakat pesisir untuk berjalan di atas genangan air atau lumpur.

## Jenis Egrang
1. **Egrang Bambu**: Terbuat dari bambu utuh dengan pijakan
2. **Egrang Batok**: Menggunakan batok kelapa sebagai pijakan
3. **Egrang Tinggi**: Untuk pertunjukan dengan ketinggian mencapai 2-3 meter

## Manfaat
Bermain egrang memberikan banyak manfaat:
- Melatih keseimbangan tubuh
- Meningkatkan konsentrasi
- Memperkuat otot kaki
- Mengembangkan keberanian
- Melatih kerja sama dalam lomba estafet

## Perlombaan
Egrang sering dilombakan dalam perayaan 17 Agustus dan acara budaya lainnya. Lomba egrang dapat berupa:
- Lomba kecepatan
- Lomba estafet
- Lomba melewati rintangan
- Lomba ketahanan (jarak terjauh)

## Nilai Edukatif
Permainan ini mengajarkan anak-anak tentang kesabaran, ketekunan, dan pantang menyerah karena butuh latihan berulang untuk menguasai teknik bermain egrang.
''',
          },
          {
            'name': 'Sepak Takraw',
            'region': 'Indonesia, Asia Tenggara',
            'description': 'Permainan menendang bola rotan melewati net',
            'xp': 20,
            'imageUrl': null,
            'fullContent': '''
# Sepak Takraw

## Asal Usul
Sepak Takraw adalah olahraga tradisional yang populer di Asia Tenggara, termasuk Indonesia. Nama "takraw" berasal dari bahasa Thai yang berarti "bola rotan", sementara "sepak" berarti menendang.

## Cara Bermain
Permainan ini mirip dengan voli, namun pemain hanya boleh menggunakan kaki, kepala, dada, dan lutut untuk memainkan bola. Tangan tidak diperbolehkan menyentuh bola kecuali saat servis.

### Aturan Dasar:
- Dimainkan oleh 2 regu (masing-masing 3 pemain)
- Menggunakan bola rotan atau plastik
- Net setinggi 1,52 meter
- Lapangan 13,4 x 6,1 meter
- Sistem poin rally (setiap rally menghasilkan poin)

## Teknik Dasar
1. **Sepak Sila**: Menendang dengan sisi dalam kaki
2. **Sepak Kuda**: Menendang dengan sisi luar kaki
3. **Sepak Cungkil**: Menendang dengan ujung kaki
4. **Heading**: Menyundul dengan kepala
5. **Smash**: Serangan keras dari atas

## Kompetisi
Sepak Takraw dipertandingkan dalam berbagai kejuaraan:
- SEA Games
- Asian Games
- Kejuaraan Dunia Sepak Takraw
- ISTAF Super Series

## Daya Tarik
Olahraga ini menuntut kelincahan, akrobatik, dan koordinasi tim yang sangat tinggi. Gerakan-gerakan spektakuler seperti smash salto membuat sepak takraw sangat menarik untuk ditonton.

## Indonesia di Kancah Internasional
Tim Indonesia telah meraih berbagai prestasi di ajang internasional dan menjadi salah satu kekuatan sepak takraw di Asia Tenggara.
''',
          },
          {
            'name': 'Balap Karung',
            'region': 'Berbagai Daerah',
            'description': 'Lomba lari sambil melompat dalam karung',
            'xp': 10,
            'imageUrl': null,
            'fullContent': '''
# Balap Karung

## Deskripsi
Balap Karung adalah permainan tradisional yang sangat populer dalam perayaan kemerdekaan Indonesia setiap tanggal 17 Agustus. Permainan sederhana namun menghibur ini selalu menjadi favorit berbagai kalangan usia.

## Cara Bermain
Peserta memasukkan kedua kaki ke dalam karung goni hingga setinggi pinggang, kemudian berlari atau melompat-lompat menuju garis finis. Peserta yang pertama mencapai finis adalah pemenangnya.

### Persiapan:
- Karung goni atau karung beras berukuran besar
- Lintasan lurus sepanjang 20-30 meter
- Garis start dan finis yang jelas
- Penonton untuk menyemangati peserta

## Strategi Menang
- Pegang erat karung di pinggang
- Lompatan kecil-kecil lebih cepat daripada lompatan besar
- Jaga keseimbangan tubuh
- Jangan terburu-buru agar tidak jatuh
- Fokus pada garis finis

## Nilai Permainan
Balap karung mengajarkan:
- Sportivitas dan fair play
- Kegembiraan dalam berkompetisi
- Pentingnya keseimbangan
- Semangat pantang menyerah
- Keceriaan dan kebersamaan

## Variasi
Beberapa variasi balap karung:
- Balap karung estafet
- Balap karung berkelompok
- Balap karung dengan rintangan
- Balap karung mundur

## Makna Sosial
Permainan ini menghilangkan sekat status sosial karena siapa pun bisa bermain dan menang. Tawa dan keceriaan yang ditimbulkan memperkuat ikatan sosial dalam masyarakat.
''',
          },
          {
            'name': 'Benteng-Bentengan',
            'region': 'Berbagai Daerah',
            'description': 'Permainan strategi merebut benteng lawan',
            'xp': 15,
            'imageUrl': null,
            'fullContent': '''
# Benteng-Bentengan

## Pengenalan
Benteng-Bentengan adalah permainan kelompok tradisional yang membutuhkan strategi, kecepatan, dan kerja sama tim. Permainan ini sangat populer di kalangan anak-anak Indonesia.

## Cara Bermain
Permainan ini dimainkan oleh dua kelompok yang masing-masing memiliki "benteng" (biasanya tiang, pohon, atau tembok). Tujuan permainan adalah menyentuh benteng lawan sambil menghindari tangkapan.

### Aturan Main:
1. Bagi pemain menjadi 2 kelompok (masing-masing 4-8 orang)
2. Tentukan benteng masing-masing kelompok
3. Pemain yang keluar lebih dulu dari benteng bisa menangkap lawan yang keluar setelahnya
4. Pemain yang tertangkap menjadi "tawanan" dan berdiri di dekat benteng lawan
5. Tawanan bisa dibebaskan oleh teman satu tim dengan menyentuhnya
6. Kelompok yang berhasil menyentuh benteng lawan menang

## Strategi Bermain
- **Penjaga**: Beberapa pemain menjaga benteng
- **Penyerang**: Pemain yang mencoba menyentuh benteng lawan
- **Umpan**: Pemain yang mengalihkan perhatian lawan
- **Penyelamat**: Pemain yang membebaskan tawanan

## Nilai Edukatif
Permainan ini mengajarkan:
- Kerja sama tim
- Strategi dan taktik
- Kepemimpinan
- Pengambilan keputusan cepat
- Sportivitas

## Pengembangan Karakter
Benteng-bentengan melatih anak untuk:
- Berpikir kritis
- Bekerja dalam tim
- Menghormati aturan
- Mengembangkan fisik dan mental
- Bersosialisasi dengan teman sebaya

## Modernisasi
Meskipun teknologi berkembang pesat, permainan ini tetap relevan sebagai sarana:
- Olahraga fisik di era digital
- Pembelajaran kerja sama
- Hiburan tanpa gadget
- Pelestarian budaya lokal
''',
          },
        ];

      case 'Tarian':
        return [
          // ... (isi data seperti semula)
          {
            'name': 'Tari Saman',
            'region': 'Aceh',
            'description': 'Tarian massal dengan gerakan kompak',
            'xp': 25,
            'imageUrl': null,
            'fullContent': '''
# Tari Saman

## Sejarah
Tari Saman adalah tarian tradisional suku Gayo yang berasal dari Aceh. Tarian ini diciptakan oleh Syekh Saman, seorang ulama dari Gayo pada abad ke-14, sebagai media dakwah Islam.

## Keunikan
Tari Saman sangat unik karena:
- Dimainkan oleh puluhan penari dalam posisi duduk dan berlutut
- Gerakan sangat cepat, kompak, dan dinamis
- Tidak menggunakan alat musik, hanya tepuk tangan, tepuk dada, dan nyanyian
- Gerakan kepala yang sinkron dan menakjubkan

## Filosofi
Setiap gerakan dalam Tari Saman memiliki makna:
- Mengajarkan nilai kebersamaan
- Melatih kedisiplinan
- Simbol kerukunan dalam masyarakat
- Representasi kekompakan dalam kehidupan

## Pengakuan UNESCO
Pada tahun 2011, UNESCO menetapkan Tari Saman sebagai Warisan Budaya Tak Benda yang Memerlukan Perlindungan Mendesak (Representative List of the Intangible Cultural Heritage of Humanity).

## Pertunjukan Modern
Saat ini, Tari Saman sering ditampilkan dalam:
- Acara kenegaraan
- Festival budaya internasional
- Pembukaan event olahraga
- Penyambutan tamu negara
- Upacara pernikahan adat Aceh
''',
          },
          {
            'name': 'Tari Kecak',
            'region': 'Bali',
            'description': 'Tarian dengan nyanyian "cak" tanpa alat musik',
            'xp': 20,
            'imageUrl': null,
            'fullContent': '''
# Tari Kecak

## Asal Usul
Tari Kecak diciptakan pada tahun 1930-an oleh seniman Bali bernama Wayan Limbak bekerja sama dengan pelukis Jerman Walter Spies. Tarian ini terinspirasi dari ritual Sanghyang dan epik Ramayana.

## Karakteristik Unik
- Dibawakan oleh 50-150 penari pria
- Duduk melingkar dengan torso telanjang
- Tidak menggunakan alat musik sama sekali
- Hanya menggunakan suara "cak-cak-cak" yang konstan
- Gerakan tangan dan badan yang dramatis

## Cerita Ramayana
Tari Kecak menceritakan kisah penculikan Dewi Sita oleh Rahwana, dan penyelamatan oleh Rama dengan bantuan Hanoman dan pasukan kera.

### Tokoh Utama:
- **Rama**: Pangeran dari Ayodya
- **Sita**: Istri Rama yang diculik
- **Rahwana**: Raja raksasa yang menculik Sita
- **Hanoman**: Kera putih pembantu Rama

## Lokasi Pertunjukan
Tempat populer menonton Tari Kecak:
- Pura Uluwatu (dengan sunset background)
- Tanah Lot
- Ubud
- Batubulan

## Daya Tarik Wisata
Tari Kecak menjadi salah satu daya tarik utama pariwisata Bali karena:
- Visual yang menakjubkan
- Suara yang menggetarkan
- Cerita yang menarik
- Lokasi pertunjukan yang spektakuler
''',
          },
        ];

      case 'Alat Musik':
        return [
          // ... (isi data seperti semula)
          {
            'name': 'Angklung',
            'region': 'Jawa Barat',
            'description': 'Alat musik dari bambu yang digoyangkan',
            'xp': 20,
            'imageUrl': null,
            'fullContent': '''
# Angklung

## Sejarah
Angklung adalah alat musik tradisional Indonesia yang terbuat dari bambu. Alat musik ini berasal dari Jawa Barat dan telah ada sejak abad ke-7 Masehi. Pada tahun 2010, UNESCO mengakui Angklung sebagai Warisan Budaya Tak Benda dari Indonesia.

## Konstruksi
Angklung terdiri dari:
- Rangka bambu sebagai wadah
- 2-4 tabung bambu yang menghasilkan nada
- Sistem penggantung yang memungkinkan tabung bergetar
- Setiap angklung menghasilkan satu nada tertentu

## Cara Memainkan
Angklung dimainkan dengan cara digoyangkan, sehingga tabung bambu bergetar dan menghasilkan suara. Untuk memainkan melodi, diperlukan beberapa orang yang masing-masing memegang angklung dengan nada berbeda.

## Perkembangan Modern
Daeng Soetigna mengembangkan angklung modern (angklung padaeng) pada tahun 1938 dengan:
- Tangga nada diatonis
- Lebih mudah dimainkan bersama alat musik modern
- Dapat memainkan lagu-lagu internasional

## Manfaat Edukatif
Bermain angklung mengajarkan:
- Kerja sama tim
- Konsentrasi dan fokus
- Apresiasi musik
- Keterampilan motorik
- Disiplin

## Populer di Dunia
Angklung kini dimainkan di berbagai negara dan menjadi alat pembelajaran musik di banyak sekolah internasional.
''',
          },
        ];

      default:
        return [];
    }
  }
}
