import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class HomeProvider extends ChangeNotifier {
  int _userXP = 0;
  int _userLevel = 1;
  bool _isLoading = false;
  String? _error;

  // Getters
  int get userXP => _userXP;
  int get userLevel => _userLevel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // XP needed for next level (100 XP per level)
  int get xpForNextLevel => 100;
  double get progressToNextLevel => (_userXP % xpForNextLevel) / xpForNextLevel;

  /// Initialize user data from Supabase
  Future<void> initializeUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = SupabaseConfig.currentUser?.id;

      if (userId == null) {
        debugPrint('⚠️ User not authenticated, using default values');
        _userXP = 0;
        _userLevel = 1;
        _error = null;
      } else {
        // Fetch from Supabase
        final userData =
            await SupabaseConfig.client
                .from('users')
                .select('total_exp, level')
                .eq('id', userId)
                .single();

        _userXP = userData['total_exp'] ?? 0;
        _userLevel = userData['level'] ?? 1;
        _error = null;

        debugPrint('✅ Loaded user data: Level $_userLevel, $_userXP XP');
      }
    } catch (e) {
      _error = 'Failed to load user data: $e';
      debugPrint('❌ HomeProvider.initializeUserData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync user XP and level from database
  Future<void> syncUserProgress() async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) return;

      final userData =
          await SupabaseConfig.client
              .from('users')
              .select('total_exp, level')
              .eq('id', userId)
              .single();

      _userXP = userData['total_exp'] ?? 0;
      _userLevel = userData['level'] ?? 1;

      notifyListeners();
      debugPrint('🔄 Synced user progress: Level $_userLevel, $_userXP XP');
    } catch (e) {
      debugPrint('❌ Error syncing user progress: $e');
    }
  }

  /// Claim XP and update level (database handles level calculation)
  Future<void> claimXP(int xp) async {
    if (xp <= 0) return;

    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ User not authenticated, XP not saved');
        return;
      }

      // Update in database (function handles level calculation)
      await SupabaseConfig.client.rpc(
        'add_user_exp',
        params: {'p_user_id': userId, 'p_exp': xp},
      );

      // Sync updated data
      await syncUserProgress();

      debugPrint('✅ Claimed $xp XP! Total: $_userXP, Level: $_userLevel');
    } catch (e) {
      debugPrint('❌ Error claiming XP: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Reset XP and level (for testing or user reset)
  void resetProgress() {
    _userXP = 0;
    _userLevel = 1;
    notifyListeners();
    debugPrint('🔄 Progress reset');
  }

  /// Manually set XP and level (for admin or testing)
  void setProgress(int xp, int level) {
    _userXP = xp;
    _userLevel = level;
    notifyListeners();
    debugPrint('📝 Progress set to: Level $level, $xp XP');
  }
}
