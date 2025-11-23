import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

/// Service untuk handle collectibles integration dengan Supabase
class CollectiblesService {
  /// Load user's collectibles dengan unlock status
  static Future<List<Map<String, dynamic>>> loadUserCollectibles(
    String userId,
  ) async {
    try {
      debugPrint('🎁 Loading user collectibles from Supabase...');
      debugPrint('   User ID: $userId');

      // Get user's character first
      final userData =
          await SupabaseConfig.client
              .from('users')
              .select('character_id, total_exp')
              .eq('id', userId)
              .single();

      final characterId = userData['character_id'];
      final userXP = userData['total_exp'];

      if (characterId == null) {
        debugPrint('⚠️ User has no character assigned yet');
        return [];
      }

      debugPrint('   Character ID: $characterId');
      debugPrint('   User XP: $userXP');

      // Load collectibles for this character with unlock status
      final collectiblesData = await SupabaseConfig.client
          .from('collectibles')
          .select('''
          id,
          name,
          description,
          image_url,
          exp_required,
          order_number,
          user_collectibles!left (
            is_unlocked,
            unlocked_at
          )
        ''')
          .eq('character_id', characterId)
          .eq('user_collectibles.user_id', userId)
          .order('order_number');

      debugPrint('✅ Loaded ${collectiblesData.length} collectibles');

      // Parse and format data
      List<Map<String, dynamic>> collectibles = [];

      for (var item in collectiblesData) {
        final unlockData = item['user_collectibles'] as List?;
        final isUnlocked =
            unlockData != null &&
            unlockData.isNotEmpty &&
            unlockData[0]['is_unlocked'] == true;

        collectibles.add({
          'id': item['id'],
          'name': item['name'],
          'description': item['description'] ?? '',
          'imageUrl': item['image_url'] ?? '',
          'xpEarned': item['exp_required'],
          'isUnlocked': isUnlocked,
          'unlockedAt':
              unlockData != null && unlockData.isNotEmpty
                  ? unlockData[0]['unlocked_at']
                  : null,
          'orderNumber': item['order_number'],
        });
      }

      return collectibles;
    } catch (e) {
      debugPrint('❌ Error loading collectibles: $e');
      rethrow;
    }
  }

  /// Manually unlock a collectible (normally handled by trigger)
  static Future<void> unlockCollectible({
    required String userId,
    required String collectibleId,
  }) async {
    try {
      debugPrint('🔓 Unlocking collectible manually...');
      debugPrint('   User ID: $userId');
      debugPrint('   Collectible ID: $collectibleId');

      await SupabaseConfig.client.from('user_collectibles').upsert({
        'user_id': userId,
        'collectible_id': collectibleId,
        'is_unlocked': true,
        'unlocked_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Collectible unlocked successfully');
    } catch (e) {
      debugPrint('❌ Error unlocking collectible: $e');
      rethrow;
    }
  }

  /// Get collectible count summary
  static Future<Map<String, int>> getCollectiblesSummary(String userId) async {
    try {
      final collectibles = await loadUserCollectibles(userId);

      final total = collectibles.length;
      final unlocked =
          collectibles.where((c) => c['isUnlocked'] == true).length;

      return {'total': total, 'unlocked': unlocked, 'locked': total - unlocked};
    } catch (e) {
      debugPrint('❌ Error getting collectibles summary: $e');
      return {'total': 0, 'unlocked': 0, 'locked': 0};
    }
  }
}
