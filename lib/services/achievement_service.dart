import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

/// Service untuk handle achievement system
class AchievementService {
  /// Load all available achievements
  static Future<List<Map<String, dynamic>>> loadAchievements() async {
    try {
      debugPrint('🏆 Loading achievements from Supabase...');

      final achievements = await SupabaseConfig.client
          .from('achievements')
          .select('*')
          .order('exp_reward');

      debugPrint('✅ Loaded ${achievements.length} achievements');

      return List<Map<String, dynamic>>.from(achievements);
    } catch (e) {
      debugPrint('❌ Error loading achievements: $e');
      return [];
    }
  }

  /// Load user achievements with progress
  static Future<List<Map<String, dynamic>>> loadUserAchievements(
    String userId,
  ) async {
    try {
      debugPrint('🏆 Loading user achievements for $userId...');

      final userAchievements = await SupabaseConfig.client
          .from('user_achievements')
          .select('''
            *,
            achievements:achievement_id (
              id,
              name,
              description,
              type,
              exp_reward,
              icon_url,
              criteria
            )
          ''')
          .eq('user_id', userId);

      debugPrint('✅ Loaded ${userAchievements.length} user achievements');

      return List<Map<String, dynamic>>.from(userAchievements);
    } catch (e) {
      debugPrint('❌ Error loading user achievements: $e');
      return [];
    }
  }

  /// Check and unlock achievement if criteria met
  static Future<bool> checkAndUnlockAchievement({
    required String userId,
    required String achievementId,
    Map<String, dynamic>? progressData,
  }) async {
    try {
      debugPrint('🏆 Checking achievement $achievementId for user $userId');

      // Check if already achieved
      final existing =
          await SupabaseConfig.client
              .from('user_achievements')
              .select()
              .eq('user_id', userId)
              .eq('achievement_id', achievementId)
              .eq('is_completed', true)
              .maybeSingle();

      if (existing != null) {
        debugPrint('⚠️ Achievement already unlocked');
        return false;
      }

      // Get achievement details
      final achievement =
          await SupabaseConfig.client
              .from('achievements')
              .select()
              .eq('id', achievementId)
              .single();

      // Insert or update user achievement
      final userAchievement =
          await SupabaseConfig.client
              .from('user_achievements')
              .upsert({
                'user_id': userId,
                'achievement_id': achievementId,
                'is_completed': true,
                'achieved_at': DateTime.now().toIso8601String(),
                'progress': progressData ?? {'current': 0},
              })
              .select()
              .single();

      // Add XP reward to user
      final expReward = achievement['exp_reward'] as int? ?? 0;
      if (expReward > 0) {
        await SupabaseConfig.client.rpc(
          'add_user_exp',
          params: {'p_user_id': userId, 'p_exp': expReward},
        );
      }

      debugPrint('✅ Achievement unlocked! +$expReward XP');
      return true;
    } catch (e) {
      debugPrint('❌ Error unlocking achievement: $e');
      return false;
    }
  }

  /// Update achievement progress
  static Future<bool> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required Map<String, dynamic> progressData,
  }) async {
    try {
      await SupabaseConfig.client.from('user_achievements').upsert({
        'user_id': userId,
        'achievement_id': achievementId,
        'progress': progressData,
      });

      debugPrint('✅ Achievement progress updated');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating achievement progress: $e');
      return false;
    }
  }

  /// Track specific events for achievements
  ///
  /// Example usage:
  /// ```dart
  /// await AchievementService.trackEvent(
  ///   userId: userId,
  ///   eventType: 'quiz_completed',
  /// );
  /// ```
  static Future<void> trackEvent({
    required String userId,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('📊 Tracking event: $eventType for user $userId');

      switch (eventType) {
        case 'first_login':
          await checkAndUnlockAchievement(
            userId: userId,
            achievementId: await _getAchievementIdByAction('first_login'),
          );
          break;

        case 'quiz_completed':
          await checkAndUnlockAchievement(
            userId: userId,
            achievementId: await _getAchievementIdByAction('complete_quiz'),
          );
          break;

        case 'museum_visited':
          final visitCount = metadata?['visit_count'] ?? 1;
          if (visitCount >= 1) {
            await checkAndUnlockAchievement(
              userId: userId,
              achievementId: await _getAchievementIdByAction('museums_visited'),
              progressData: {'museums_visited': visitCount},
            );
          }
          break;

        case 'collectible_unlocked':
          final unlockedCount = metadata?['unlocked_count'] ?? 0;
          if (unlockedCount >= 3) {
            await checkAndUnlockAchievement(
              userId: userId,
              achievementId: await _getAchievementIdByAction(
                'collectibles_unlocked',
              ),
              progressData: {'collectibles_unlocked': unlockedCount},
            );
          }
          break;

        case 'level_reached':
          final level = metadata?['level'] ?? 1;
          if (level >= 10) {
            await checkAndUnlockAchievement(
              userId: userId,
              achievementId: await _getAchievementIdByAction('level_reached'),
              progressData: {'level_reached': level},
            );
          }
          break;

        default:
          debugPrint('⚠️ Unknown event type: $eventType');
      }
    } catch (e) {
      debugPrint('❌ Error tracking event: $e');
    }
  }

  /// Helper to get achievement ID by criteria action
  static Future<String> _getAchievementIdByAction(String action) async {
    try {
      final achievement =
          await SupabaseConfig.client
              .from('achievements')
              .select('id')
              .contains('criteria', {'action': action})
              .single();

      return achievement['id'] as String;
    } catch (e) {
      // If not found by action, try by other criteria keys
      final achievements = await SupabaseConfig.client
          .from('achievements')
          .select('*');

      for (final ach in achievements) {
        final criteria = ach['criteria'] as Map<String, dynamic>?;
        if (criteria != null && criteria.containsKey(action)) {
          return ach['id'] as String;
        }
      }

      throw Exception('Achievement not found for action: $action');
    }
  }
}
