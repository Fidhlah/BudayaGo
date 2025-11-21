import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

/// Service untuk handle eksplorasi/cultural content integration
class EksplorasiService {
  /// Load all cultural categories (10 OPK)
  static Future<List<Map<String, dynamic>>> loadCategories() async {
    try {
      debugPrint('📚 Loading cultural categories from Supabase...');

      final categories = await SupabaseConfig.client
          .from('cultural_categories')
          .select('*')
          .eq('is_active', true)
          .order('order_number');

      debugPrint('✅ Loaded ${categories.length} categories');

      return List<Map<String, dynamic>>.from(categories);
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
      return [];
    }
  }

  /// Load all provinces
  static Future<List<Map<String, dynamic>>> loadProvinces() async {
    try {
      debugPrint('🗺️ Loading provinces from Supabase...');

      final provinces = await SupabaseConfig.client
          .from('provinces')
          .select('*')
          .order('name');

      debugPrint('✅ Loaded ${provinces.length} provinces');

      return List<Map<String, dynamic>>.from(provinces);
    } catch (e) {
      debugPrint('❌ Error loading provinces: $e');
      return [];
    }
  }

  /// Load content by category
  static Future<List<Map<String, dynamic>>> loadContentByCategory(
    String categoryId,
  ) async {
    try {
      debugPrint('📖 Loading content for category: $categoryId');

      final content = await SupabaseConfig.client
          .from('cultural_content')
          .select('''
          *,
          cultural_categories (
            name,
            icon_name,
            color
          ),
          provinces (
            name,
            icon_emoji
          )
        ''')
          .eq('category_id', categoryId)
          .eq('is_verified', true)
          .order('created_at', ascending: false);

      debugPrint('✅ Loaded ${content.length} content items');

      return List<Map<String, dynamic>>.from(content);
    } catch (e) {
      debugPrint('❌ Error loading content: $e');
      return [];
    }
  }

  /// Load content by province
  static Future<List<Map<String, dynamic>>> loadContentByProvince(
    String provinceId,
  ) async {
    try {
      debugPrint('📍 Loading content for province: $provinceId');

      final content = await SupabaseConfig.client
          .from('cultural_content')
          .select('''
          *,
          cultural_categories (
            name,
            icon_name,
            color
          ),
          provinces (
            name,
            icon_emoji
          )
        ''')
          .eq('province_id', provinceId)
          .eq('is_verified', true)
          .order('created_at', ascending: false);

      debugPrint('✅ Loaded ${content.length} content items');

      return List<Map<String, dynamic>>.from(content);
    } catch (e) {
      debugPrint('❌ Error loading content: $e');
      return [];
    }
  }

  /// Search content
  static Future<List<Map<String, dynamic>>> searchContent(String query) async {
    try {
      debugPrint('🔍 Searching content with query: $query');

      final content = await SupabaseConfig.client
          .from('cultural_content')
          .select('''
          *,
          cultural_categories (
            name,
            icon_name,
            color
          ),
          provinces (
            name,
            icon_emoji
          )
        ''')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('is_verified', true)
          .order('created_at', ascending: false);

      debugPrint('✅ Found ${content.length} content items');

      return List<Map<String, dynamic>>.from(content);
    } catch (e) {
      debugPrint('❌ Error searching content: $e');
      return [];
    }
  }

  /// Load featured content
  static Future<List<Map<String, dynamic>>> loadFeaturedContent() async {
    try {
      debugPrint('⭐ Loading featured content...');

      final content = await SupabaseConfig.client
          .from('cultural_content')
          .select('''
          *,
          cultural_categories (
            name,
            icon_name,
            color
          ),
          provinces (
            name,
            icon_emoji
          )
        ''')
          .eq('is_featured', true)
          .eq('is_verified', true)
          .order('created_at', ascending: false)
          .limit(10);

      debugPrint('✅ Loaded ${content.length} featured items');

      return List<Map<String, dynamic>>.from(content);
    } catch (e) {
      debugPrint('❌ Error loading featured content: $e');
      return [];
    }
  }

  /// Get content detail
  static Future<Map<String, dynamic>?> getContentDetail(
    String contentId,
  ) async {
    try {
      final content =
          await SupabaseConfig.client
              .from('cultural_content')
              .select('''
          *,
          cultural_categories (
            name,
            icon_name,
            color
          ),
          provinces (
            name,
            icon_emoji
          ),
          users!cultural_content_created_by_fkey (
            display_name,
            username
          )
        ''')
              .eq('id', contentId)
              .single();

      return content;
    } catch (e) {
      debugPrint('❌ Error getting content detail: $e');
      return null;
    }
  }

  /// Increment view count
  static Future<void> incrementViewCount(String contentId) async {
    try {
      await SupabaseConfig.client.rpc(
        'increment_view_count',
        params: {'content_id': contentId},
      );
    } catch (e) {
      debugPrint('❌ Error incrementing view count: $e');
    }
  }

  /// Record content read (give XP)
  static Future<Map<String, dynamic>> recordContentRead({
    required String userId,
    required String contentId,
    required int xpReward,
  }) async {
    try {
      debugPrint('📖 Recording content read...');

      // Add XP to user
      await SupabaseConfig.client.rpc(
        'add_user_exp',
        params: {'p_user_id': userId, 'p_exp': xpReward},
      );

      // Increment view count
      await incrementViewCount(contentId);

      debugPrint('✅ Content read recorded, +$xpReward XP');

      return {'success': true, 'xp_gained': xpReward};
    } catch (e) {
      debugPrint('❌ Error recording content read: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get content stats
  static Future<Map<String, int>> getContentStats() async {
    try {
      final content = await SupabaseConfig.client
          .from('cultural_content')
          .select('id, view_count, like_count');

      final totalContent = content.length;
      final totalViews = content.fold<int>(
        0,
        (sum, item) => sum + (item['view_count'] as int? ?? 0),
      );
      final totalLikes = content.fold<int>(
        0,
        (sum, item) => sum + (item['like_count'] as int? ?? 0),
      );

      return {
        'totalContent': totalContent,
        'totalViews': totalViews,
        'totalLikes': totalLikes,
      };
    } catch (e) {
      debugPrint('❌ Error getting content stats: $e');
      return {'totalContent': 0, 'totalViews': 0, 'totalLikes': 0};
    }
  }

  /// Load home carousel/banner content
  static Future<List<Map<String, dynamic>>> loadHomeContent() async {
    try {
      debugPrint('🏠 Loading home banner content...');

      final content = await SupabaseConfig.client
          .from('content_home')
          .select('*')
          .eq('is_active', true)
          .order('order_number');

      debugPrint('✅ Loaded ${content.length} home banners');

      return List<Map<String, dynamic>>.from(content);
    } catch (e) {
      debugPrint('❌ Error loading home content: $e');
      return [];
    }
  }
}
