import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/qr_code_model.dart';

/// ✅ SERVICE LAYER: Handle all QR-related logic
class QrService {
  /// Parse scanned QR code
  QRCodeModel? parseQrCode(BarcodeCapture capture) {
    // ✅ FIX: Use safe access instead of firs`tOrNull
    if (capture.barcodes.isEmpty) {
      print('⚠️ No barcodes detected');
      return null;
    }

    final barcode = capture.barcodes.first;
    
    if (barcode.rawValue == null || barcode.rawValue!.isEmpty) {
      print('⚠️ Barcode has no data');
      return null;
    }

    try {
      print('📄 Parsing QR data: ${barcode.rawValue}');
      
      // ✅ DECODE: QR string format "PREFIX:BASE64"
      final qrCode = QRCodeModel.decode(
        qrString: barcode.rawValue!,
      );
      
      print('✅ QR decoded successfully!');
      print('   UUID: ${qrCode.uuid}');
      print('   Version: ${qrCode.version}');
      
      return qrCode;
      
    } catch (e) {
      print('❌ QR Parse Error: $e');
      return null;
    }
  }

  /// Validate QR code
  bool validateQrCode(QRCodeModel qrCode) {
    print('🔍 Validating QR code...');
    print('   UUID: ${qrCode.uuid}');
    print('   Version: ${qrCode.version}');

    // ✅ Basic validation: UUID tidak boleh kosong
    final isValid = qrCode.uuid.isNotEmpty && 
                    qrCode.version > 0;

    print(isValid ? '✅ QR code valid' : '❌ QR code invalid');
    return isValid;
  }

  /// Generate QR code data (for testing)
  /// 
  /// Returns encoded QR string: "PREFIX:BASE64"
  String generateQrCodeData({
    required String uuid,
    int version = 1,
  }) {
    final qrCode = QRCodeModel(
      uuid: uuid,
      version: version,
    );
    
    // ✅ ENCODE: Returns "LANGKARA-o2o:BASE64..."
    final encodedData = qrCode.encode();
    
    print('🔨 Generated QR data: $encodedData');
    return encodedData;
  }
}