/// Test data untuk geofencing
/// Digunakan untuk development/testing sebelum connect ke database
class TestLocations {
  // Map QR Code -> Location Data
  static final Map<String, Map<String, dynamic>> locations = {
    'hafidh01': {
      'name': 'Rumah Hafidh',
      'lat': -6.93415426659206,
      'lng': 107.61479739897182,
      'radius': 100,
      'description': 'Rumah untuk testing',
    },
    'borobudur001': {
      'name': 'Candi Borobudur',
      'lat': -7.6079,
      'lng': 110.2038,
      'radius': 100,
      'description': 'Candi Buddha terbesar di dunia',
    },
    'prambanan001': {
      'name': 'Candi Prambanan',
      'lat': -7.7520,
      'lng': 110.4915,
      'radius': 100,
      'description': 'Candi Hindu terbesar di Indonesia',
    },
    'keraton001': {
      'name': 'Keraton Yogyakarta',
      'lat': -7.8053,
      'lng': 110.3644,
      'radius': 150,
      'description': 'Istana resmi Kesultanan Yogyakarta',
    },
    'monas001': {
      'name': 'Monumen Nasional',
      'lat': -6.1754,
      'lng': 106.8272,
      'radius': 150,
      'description': 'Monumen peringatan kemerdekaan Indonesia',
    },
    'tmii001': {
      'name': 'Taman Mini Indonesia Indah',
      'lat': -6.3025,
      'lng': 106.8954,
      'radius': 200,
      'description': 'Taman rekreasi kebudayaan Indonesia',
    },
  };

  /// Get location data by QR code (case-insensitive)
  static Map<String, dynamic>? getLocation(String qrCode) {
    final key = qrCode.toLowerCase().trim();
    return locations[key];
  }

  /// Check if QR code exists (case-insensitive)
  static bool isValidQRCode(String qrCode) {
    final key = qrCode.toLowerCase().trim();
    return locations.containsKey(key);
  }

  /// Get all location names
  static List<String> getAllLocationNames() {
    return locations.values.map((loc) => loc['name'] as String).toList();
  }

  /// Get all QR codes
  static List<String> getAllQRCodes() {
    return locations.keys.toList();
  }
}