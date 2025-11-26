import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

/// Service untuk handle karya (UMKM products) integration dengan Supabase
class KaryaService {
  /// Get karya by user ID
  static Future<List<Map<String, dynamic>>> getKaryasByUserId(
    String userId,
  ) async {
    try {
      debugPrint('🎨 Loading karya for user: $userId');

      final karyaData = await SupabaseConfig.client
          .from('karya')
          .select('''
          id,
          name,
          description,
          tag,
          image_url,
          icon_code_point,
          likes,
          views,
          created_at
          ''')
          .eq('creator_id', userId)
          .order('created_at', ascending: false);

      debugPrint('✅ Loaded ${karyaData.length} karya for user');
      return List<Map<String, dynamic>>.from(karyaData);
    } catch (e) {
      debugPrint('❌ Error loading karya for user: $e');
      return [];
    }
  }

  /// Load semua karya dari database
  static Future<List<Map<String, dynamic>>> loadAllKarya() async {
    try {
      debugPrint('🎨 Loading all karya from Supabase...');

      final karyaData = await SupabaseConfig.client
          .from('karya')
          .select('''
          id,
          name,
          description,
          image_url,
          tag,
          umkm_category,
          color,
          icon_code_point,
          likes,
          views,
          created_at,
          creator_id,
          users!karya_creator_id_fkey (
            id,
            display_name,
            username,
            is_pelaku_budaya,
            hide_progress
          )
        ''')
          .order('created_at', ascending: false);

      debugPrint('✅ Loaded ${karyaData.length} karya items');
      if (karyaData.isEmpty) {
        debugPrint(
          '⚠️ No karya found in database. Make sure to upload some karya first.',
        );
      }

      return List<Map<String, dynamic>>.from(karyaData);
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading karya: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Load karya by specific tag
  static Future<List<Map<String, dynamic>>> loadKaryaByTag(String tag) async {
    try {
      debugPrint('🏷️ Loading karya with tag: $tag');

      final karyaData = await SupabaseConfig.client
          .from('karya')
          .select('''
          id,
          name,
          description,
          image_url,
          tag,
          umkm_category,
          color,
          icon_code_point,
          likes,
          views,
          created_at,
          creator_id,
          users!karya_creator_id_fkey (
            id,
            display_name,
            username,
            is_pelaku_budaya,
            hide_progress
          )
        ''')
          .eq('tag', tag)
          .order('created_at', ascending: false);

      debugPrint('✅ Loaded ${karyaData.length} karya items with tag: $tag');

      return List<Map<String, dynamic>>.from(karyaData);
    } catch (e) {
      debugPrint('❌ Error loading karya by tag: $e');
      return [];
    }
  }

  /// Load karya by UMKM category
  static Future<List<Map<String, dynamic>>> loadKaryaByCategory(
    String category,
  ) async {
    try {
      debugPrint('📂 Loading karya for category: $category');

      final karyaData = await SupabaseConfig.client
          .from('karya')
          .select('''
          id,
          name,
          description,
          image_url,
          tag,
          umkm_category,
          color,
          icon_code_point,
          likes,
          views,
          created_at,
          users!karya_creator_id_fkey (
            id,
            display_name,
            username,
            is_pelaku_budaya,
            hide_progress
          )
        ''')
          .eq('umkm_category', category)
          .order('created_at', ascending: false);

      debugPrint(
        '✅ Loaded ${karyaData.length} karya items for category: $category',
      );

      return List<Map<String, dynamic>>.from(karyaData);
    } catch (e) {
      debugPrint('❌ Error loading karya by category: $e');
      return [];
    }
  }

  /// Search karya by name or description
  static Future<List<Map<String, dynamic>>> searchKarya(String query) async {
    try {
      debugPrint('🔍 Searching karya with query: $query');

      final karyaData = await SupabaseConfig.client
          .from('karya')
          .select('''
          id,
          name,
          description,
          image_url,
          tag,
          umkm_category,
          color,
          icon_code_point,
          likes,
          views,
          created_at,
          creator_id,
          users!karya_creator_id_fkey (
            id,
            display_name,
            username,
            is_pelaku_budaya,
            hide_progress
          )
        ''')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      debugPrint('✅ Found ${karyaData.length} karya items');

      return List<Map<String, dynamic>>.from(karyaData);
    } catch (e) {
      debugPrint('❌ Error searching karya: $e');
      return [];
    }
  }

  /// Create sample/dummy karya data for testing (Only use in development)
  static Future<void> createSampleKarya(String creatorId) async {
    try {
      debugPrint('🎨 Creating sample karya data...');

      final samples = [
        {
          'creator_id': creatorId,
          'name': 'Batik Parang Klasik',
          'description':
              'Batik dengan motif parang klasik yang elegan, dibuat dengan teknik tulis tradisional.',
          'tag': 'Batik',
          'umkm_category': 'Batik Nusantara',
          'color': 0xFF8B4513,
          'icon_code_point': 0xe3b7, // Icons.palette
        },
        {
          'creator_id': creatorId,
          'name': 'Kursi Ukir Jepara',
          'description':
              'Furniture kayu jati dengan ukiran detail khas Jepara, hasil karya pengrajin lokal.',
          'tag': 'Furniture',
          'umkm_category': 'Kerajinan Kayu',
          'color': 0xFF6B4423,
          'icon_code_point': 0xe8cc, // Icons.chair
        },
        {
          'creator_id': creatorId,
          'name': 'Gerabah Kasongan',
          'description':
              'Vas dan peralatan rumah tangga dari tanah liat khas Kasongan, Yogyakarta.',
          'tag': 'Keramik',
          'umkm_category': 'Gerabah Tradisional',
          'color': 0xFFD2691E,
          'icon_code_point': 0xe3b8, // Icons.vase
        },
      ];

      for (var sample in samples) {
        await SupabaseConfig.client.from('karya').insert(sample);
      }

      debugPrint('✅ Sample karya created successfully');
    } catch (e) {
      debugPrint('❌ Error creating sample karya: $e');
    }
  }

  /// Upload new karya
  static Future<Map<String, dynamic>?> uploadKarya({
    required String creatorId,
    required String name,
    required String description,
    required String tag,
    required String umkmCategory,
    String? imageUrl,
    int? color,
    int? iconCodePoint,
  }) async {
    try {
      debugPrint('📤 Uploading new karya...');
      debugPrint('   Name: $name');
      debugPrint('   Creator ID: $creatorId');

      final result =
          await SupabaseConfig.client
              .from('karya')
              .insert({
                'creator_id': creatorId,
                'name': name,
                'description': description,
                'image_url': imageUrl,
                'tag': tag,
                'umkm_category': umkmCategory,
                'color': color,
                'icon_code_point': iconCodePoint,
              })
              .select()
              .single();

      debugPrint('✅ Karya uploaded successfully with ID: ${result['id']}');

      return result;
    } catch (e) {
      debugPrint('❌ Error uploading karya: $e');
      return null;
    }
  }

  /// Get user's uploaded karya
  static Future<List<Map<String, dynamic>>> getUserKarya(String userId) async {
    try {
      debugPrint('👤 Loading karya for user: $userId');

      final karyaData = await SupabaseConfig.client
          .from('karya')
          .select('''
          id,
          name,
          description,
          image_url,
          tag,
          umkm_category,
          color,
          icon_code_point,
          likes,
          views,
          created_at
        ''')
          .eq('creator_id', userId)
          .order('created_at', ascending: false);

      debugPrint('✅ Found ${karyaData.length} karya items for user');

      return List<Map<String, dynamic>>.from(karyaData);
    } catch (e) {
      debugPrint('❌ Error loading user karya: $e');
      return [];
    }
  }

  /// Load all UMKM/Cultural Partners
  static Future<List<Map<String, dynamic>>> loadUMKMPartners() async {
    try {
      debugPrint('🏢 Loading UMKM partners from Supabase...');

      final partnersData = await SupabaseConfig.client
          .from('cultural_partners')
          .select('''
          id,
          name,
          type,
          description,
          address,
          city,
          province,
          latitude,
          longitude,
          image_url,
          contact_info,
          is_verified
        ''')
          .eq('type', 'umkm')
          .eq('is_verified', true)
          .order('name');

      debugPrint('✅ Loaded ${partnersData.length} UMKM partners');

      return List<Map<String, dynamic>>.from(partnersData);
    } catch (e) {
      debugPrint('❌ Error loading UMKM partners: $e');
      return [];
    }
  }

  /// Get UMKM partner detail by ID
  static Future<Map<String, dynamic>?> getUMKMDetail(String partnerId) async {
    try {
      final partnerData =
          await SupabaseConfig.client
              .from('cultural_partners')
              .select('''
          id,
          name,
          type,
          description,
          address,
          city,
          province,
          latitude,
          longitude,
          image_url,
          contact_info,
          is_verified,
          created_at
        ''')
              .eq('id', partnerId)
              .single();

      return partnerData;
    } catch (e) {
      debugPrint('❌ Error getting UMKM detail: $e');
      return null;
    }
  }

  /// Get karya statistics
  static Future<Map<String, int>> getKaryaStats() async {
    try {
      final karyaData = await SupabaseConfig.client
          .from('karya')
          .select('id, likes, views');

      final totalKarya = karyaData.length;
      final totalLikes = karyaData.fold<int>(
        0,
        (sum, item) => sum + (item['likes'] as int? ?? 0),
      );
      final totalViews = karyaData.fold<int>(
        0,
        (sum, item) => sum + (item['views'] as int? ?? 0),
      );

      return {
        'totalKarya': totalKarya,
        'totalLikes': totalLikes,
        'totalViews': totalViews,
      };
    } catch (e) {
      debugPrint('❌ Error getting karya stats: $e');
      return {'totalKarya': 0, 'totalLikes': 0, 'totalViews': 0};
    }
  }
}
