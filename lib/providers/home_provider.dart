import 'package:flutter/foundation.dart';

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
  double get progressToNextLevel => _userXP / xpForNextLevel;

  /// Initialize user data (could fetch from Supabase in future)
  Future<void> initializeUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Fetch from Supabase in future
      // For now, use default values
      _userXP = 0;
      _userLevel = 1;
      _error = null;
    } catch (e) {
      _error = 'Failed to load user data: $e';
      debugPrint('❌ HomeProvider.initializeUserData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Claim XP and update level if needed
  void claimXP(int xp) {
    if (xp <= 0) return;

    _userXP += xp;
    debugPrint('✅ Claimed $xp XP! Total: $_userXP');

    // Check if user leveled up
    while (_userXP >= xpForNextLevel) {
      _userXP -= xpForNextLevel;
      _userLevel++;
      debugPrint('🎉 Level up! Now level $_userLevel');
    }

    notifyListeners();

    // TODO: Sync to Supabase in future
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
