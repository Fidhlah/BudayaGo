/// Configuration untuk QR Code system
///
/// Ganti prefix di sini jika nama project berubah
class QRConfig {
  /// Prefix untuk QR Code
  /// Ganti sesuai kebutuhan project
  static const String qrPrefix = 'SEMBARA-o2o';

  /// Legacy prefixes (untuk backward compatibility)
  /// QR code dengan prefix ini masih diterima
  static const List<String> legacyPrefixes = ['LANGKARA-o2o'];

  /// Validate prefix (current atau legacy)
  static bool isValidPrefix(String prefix) {
    return prefix == qrPrefix || legacyPrefixes.contains(prefix);
  }

  /// Current QR Code version
  /// Increment jika ada breaking changes di format
  static const int currentVersion = 1;

  /// Supported versions (untuk backward compatibility)
  static const List<int> supportedVersions = [1];

  /// Validate version compatibility
  static bool isVersionSupported(int version) {
    return supportedVersions.contains(version);
  }
}
