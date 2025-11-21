import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

/// Service untuk handle visit recording dan XP rewards
class VisitService {
  /// Record visit dan berikan XP (menggunakan database function)
  static Future<Map<String, dynamic>> recordVisitAndGiveExp({
    required String userId,
    required String partnerId,
    int expGained = 500,
    String verificationMethod = 'qr_scan',
  }) async {
    try {
      debugPrint('📍 Recording visit to Supabase...');
      debugPrint('   User ID: $userId');
      debugPrint('   Partner ID: $partnerId');
      debugPrint('   EXP: $expGained');

      // Call database function (handles visit + XP + auto-unlock collectibles)
      final result =
          await SupabaseConfig.client
              .rpc(
                'record_visit_and_give_exp',
                params: {
                  'p_user_id': userId,
                  'p_partner_id': partnerId,
                  'p_exp_gained': expGained,
                  'p_verification_method': verificationMethod,
                },
              )
              .single();

      debugPrint('✅ Visit recorded successfully!');
      debugPrint('   New Total EXP: ${result['new_total_exp']}');
      debugPrint('   New Level: ${result['new_level']}');
      debugPrint(
        '   Unlocked Collectibles: ${result['unlocked_collectibles']}',
      );

      return {
        'success': result['success'],
        'message': result['message'],
        'newTotalExp': result['new_total_exp'],
        'newLevel': result['new_level'],
        'unlockedCollectibles': result['unlocked_collectibles'],
        'expGained': expGained,
      };
    } catch (e) {
      debugPrint('❌ Error recording visit: $e');
      rethrow;
    }
  }

  /// Get user's visit history
  static Future<List<Map<String, dynamic>>> getUserVisits(String userId) async {
    try {
      debugPrint('📜 Loading user visit history...');

      final visitsData = await SupabaseConfig.client
          .from('user_visits')
          .select('''
          id,
          visited_at,
          exp_gained,
          verification_method,
          cultural_partners (
            id,
            name,
            type,
            city,
            province
          )
        ''')
          .eq('user_id', userId)
          .order('visited_at', ascending: false);

      debugPrint('✅ Loaded ${visitsData.length} visits');

      return List<Map<String, dynamic>>.from(visitsData);
    } catch (e) {
      debugPrint('❌ Error loading visits: $e');
      return [];
    }
  }

  /// Check if user has visited a location today
  static Future<bool> hasVisitedToday({
    required String userId,
    required String partnerId,
  }) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final visits = await SupabaseConfig.client
          .from('user_visits')
          .select('id')
          .eq('user_id', userId)
          .eq('partner_id', partnerId)
          .gte('visited_at', startOfDay.toIso8601String())
          .limit(1);

      return visits.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking today visit: $e');
      return false;
    }
  }

  /// Get visit statistics
  static Future<Map<String, dynamic>> getVisitStats(String userId) async {
    try {
      final visitsData = await SupabaseConfig.client
          .from('user_visits')
          .select('id, visited_at, exp_gained')
          .eq('user_id', userId);

      final totalVisits = visitsData.length;
      final totalExpFromVisits = visitsData.fold<int>(
        0,
        (sum, visit) => sum + (visit['exp_gained'] as int? ?? 0),
      );

      // Get unique locations count
      final uniqueLocations = await SupabaseConfig.client
          .from('user_visits')
          .select('partner_id')
          .eq('user_id', userId);

      final uniqueLocationIds =
          uniqueLocations.map((v) => v['partner_id']).toSet().length;

      return {
        'totalVisits': totalVisits,
        'totalExpFromVisits': totalExpFromVisits,
        'uniqueLocations': uniqueLocationIds,
      };
    } catch (e) {
      debugPrint('❌ Error getting visit stats: $e');
      return {'totalVisits': 0, 'totalExpFromVisits': 0, 'uniqueLocations': 0};
    }
  }
}
