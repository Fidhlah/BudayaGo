import 'dart:convert';
import '../config/qr_config.dart'; // ✅ IMPORT CONFIG

/// Model untuk QR Code format BudayaGo/Langkara
/// Format: PREFIX:BASE64_ENCODED_JSON
/// 
/// JSON Structure:
/// {
///   "UUID": "location-uuid-from-supabase",
///   "v": 1
/// }
class QRCodeModel {
  final String uuid;
  final int version;

  QRCodeModel({
    required this.uuid,
    required this.version,
  });

  /// Create from JSON
  factory QRCodeModel.fromJson(Map<String, dynamic> json) {
    return QRCodeModel(
      uuid: json['UUID'] as String,
      version: json['v'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'UUID': uuid,
      'v': version,
    };
  }

  /// Encode QR data ke Base64 dengan prefix
  /// 
  /// Example:
  /// ```dart
  /// final qr = QRCodeModel(uuid: '123456789', version: 1);
  /// final encoded = qr.encode();
  /// // Result: "LANGKARA-o2o:eyJVVUlEIjoiMTIzNDU2Nzg5IiwidiI6MX0="
  /// ```
  String encode({String? prefix}) {
    // ✅ USE CONFIG: Default ke QRConfig.qrPrefix jika tidak di-specify
    final actualPrefix = prefix ?? QRConfig.qrPrefix;
    final jsonString = jsonEncode(toJson());
    final base64String = base64Encode(utf8.encode(jsonString));
    return '$actualPrefix:$base64String';
  }

  /// Decode QR string dengan format PREFIX:BASE64
  /// 
  /// Example:
  /// ```dart
  /// final decoded = QRCodeModel.decode(
  ///   qrString: 'LANGKARA-o2o:eyJVVUlEIjoiMTIzNDU2Nzg5IiwidiI6MX0='
  /// );
  /// ```
  /// 
  /// Throws:
  /// - [QRCodeFormatException] jika format tidak valid
  /// - [QRCodePrefixException] jika prefix tidak sesuai
  static QRCodeModel decode({
    required String qrString,
    String? expectedPrefix, // ✅ UBAH KE NULLABLE
  }) {
    try {
      // ✅ USE CONFIG: Default ke QRConfig.qrPrefix jika tidak di-specify
      final actualExpectedPrefix = expectedPrefix ?? QRConfig.qrPrefix;
      
      // 1. Split by ':'
      final parts = qrString.split(':');
      
      if (parts.length != 2) {
        throw QRCodeFormatException(
          'Invalid QR format. Expected: PREFIX:BASE64',
        );
      }

      final prefix = parts[0].trim();
      final base64Data = parts[1].trim();

      // 2. Validate prefix
      if (prefix != actualExpectedPrefix) {
        throw QRCodePrefixException(
          'Invalid prefix. Expected: "$actualExpectedPrefix", Got: "$prefix"',
        );
      }

      // 3. Decode Base64
      final decodedBytes = base64Decode(base64Data);
      final jsonString = utf8.decode(decodedBytes);

      // 4. Parse JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 5. Validate required fields
      if (!jsonData.containsKey('UUID') || !jsonData.containsKey('v')) {
        throw QRCodeFormatException(
          'Missing required fields: UUID or v',
        );
      }

      return QRCodeModel.fromJson(jsonData);
    } on FormatException catch (e) {
      throw QRCodeFormatException('Failed to decode Base64: ${e.message}');
    } catch (e) {
      if (e is QRCodeException) rethrow;
      throw QRCodeFormatException('Unknown error: $e');
    }
  }

  @override
  String toString() {
    return 'QRCodeModel(uuid: $uuid, version: $version)';
  }
}

/// Base exception untuk QR Code errors
abstract class QRCodeException implements Exception {
  final String message;
  const QRCodeException(this.message);

  @override
  String toString() => message;
}

/// Exception untuk format QR yang tidak valid
class QRCodeFormatException extends QRCodeException {
  const QRCodeFormatException(super.message);
}

/// Exception untuk prefix yang tidak sesuai
class QRCodePrefixException extends QRCodeException {
  const QRCodePrefixException(super.message);
}
