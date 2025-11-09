/// Test data untuk geofencing
/// Digunakan untuk development/testing sebelum connect ke database
class TestLocations {
  // ✅ STRUKTUR BARU: Map UUID -> Location Data
  static final Map<String, Map<String, dynamic>> locations = {
    // UUID dari Supabase (contoh)
    '650e8400-e29b-41d4-a716-446655430001': {
      'name': 'Daarut Tauhid',
      'lat': -6.863543801365466,  
      'lng': 107.58987589714985,
      'radius': 200,
      'description': 'masjid',
      // 'qrCode': 'fpmipa01', // Legacy support
    },
    '550e8400-e29b-41d4-a716-446655430001': {
      'name': 'FPMIPA',
      'lat': -6.861745707819885, 
      'lng': 107.59036323730625,
      'radius': 200,
      'description': 'UPI FPMIPA',
      // 'qrCode': 'fpmipa01', // Legacy support
    },
    '550e8400-e29b-41d4-a716-446655440001': {
      'name': 'Rumah Hafidh',
      'lat': -6.93415426659206,
      'lng': 107.61479739897182,
      'radius': 100,
      'description': 'Rumah untuk testing',
      // 'qrCode': 'hafidh01', // Legacy support
    },
    '550e8400-e29b-41d4-a716-446655440002': {
      'name': 'Candi Borobudur',
      'lat': -7.6079,
      'lng': 110.2038,
      'radius': 100,
      'description': 'Candi Buddha terbesar di dunia',
      'qrCode': 'borobudur001',
    },
    '550e8400-e29b-41d4-a716-446655440003': {
      'name': 'Candi Prambanan',
      'lat': -7.7520,
      'lng': 110.4915,
      'radius': 100,
      'description': 'Candi Hindu terbesar di Indonesia',
      'qrCode': 'prambanan001',
    },
    '550e8400-e29b-41d4-a716-446655440004': {
      'name': 'Keraton Yogyakarta',
      'lat': -7.8053,
      'lng': 110.3644,
      'radius': 150,
      'description': 'Istana resmi Kesultanan Yogyakarta',
      'qrCode': 'keraton001',
    },
  };

  /// ✅ NEW: Get location by UUID
  static Map<String, dynamic>? getLocationByUUID(String uuid) {
    return locations[uuid];
  }

  /// ✅ NEW: Check if UUID valid
  static bool isValidUUID(String uuid) {
    return locations.containsKey(uuid);
  }

  /// ⚠️ LEGACY: Get location by old QR code format
  /// Akan dihapus setelah migrasi selesai
  @Deprecated('Use getLocationByUUID instead')
  static Map<String, dynamic>? getLocation(String qrCode) {
    final key = qrCode.toLowerCase().trim();
    // Search by qrCode field
    for (var entry in locations.entries) {
      if (entry.value['qrCode']?.toLowerCase() == key) {
        return entry.value;
      }
    }
    return null;
  }

  /// ⚠️ LEGACY: Check if old QR code exists
  @Deprecated('Use isValidUUID instead')
  static bool isValidQRCode(String qrCode) {
    return getLocation(qrCode) != null;
  }

  /// Get all location names
  static List<String> getAllLocationNames() {
    return locations.values.map((loc) => loc['name'] as String).toList();
  }

  /// Get all UUIDs
  static List<String> getAllUUIDs() {
    return locations.keys.toList();
  }

  /// ⚠️ LEGACY: Get all old QR codes
  @Deprecated('Use getAllUUIDs instead')
  static List<String> getAllQRCodes() {
    return locations.values
        .where((loc) => loc['qrCode'] != null)
        .map((loc) => loc['qrCode'] as String)
        .toList();
  }
}