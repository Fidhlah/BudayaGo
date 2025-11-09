import '../models/qr_code_model.dart';
import '../config/qr_config.dart';

/// Helper untuk generate QR code saat testing
class QRGeneratorHelper {
  /// Generate QR string dari UUID
  static String generateQR(String uuid) {
    final qrCode = QRCodeModel(
      uuid: uuid,
      version: QRConfig.currentVersion,
    );
    // ✅ Encode otomatis pakai QRConfig.qrPrefix!
    return qrCode.encode();
  }

  /// Print QR codes untuk semua test locations
  static void printAllTestQRCodes() {
    print('=== TEST QR CODES ===');
    print('Prefix: ${QRConfig.qrPrefix}');
    print('Version: ${QRConfig.currentVersion}');
    print('');

    final testUUIDs = {
      '550e8400-e29b-41d4-a716-446655440001': 'Rumah Hafidh',
      '550e8400-e29b-41d4-a716-446655440002': 'Candi Borobudur',
      '550e8400-e29b-41d4-a716-446655440003': 'Candi Prambanan',
      '550e8400-e29b-41d4-a716-446655440004': 'Keraton Yogyakarta',
    };

    for (var entry in testUUIDs.entries) {
      final qrString = generateQR(entry.key);
      print('${entry.value}:');
      print('UUID: ${entry.key}');
      print('QR:   $qrString');
      print('');
    }
  }
}