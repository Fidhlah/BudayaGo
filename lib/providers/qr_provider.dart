import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/qr_code_model.dart';
import '../services/qr_service.dart';
import '../services/geofencing_service.dart';

/// ✅ PROVIDER: Manage QR scanning state
class QrProvider with ChangeNotifier {
  final QrService _qrService = QrService();
  final GeofencingService _geofencingService = GeofencingService();

  QRCodeModel? _scannedQrCode;
  bool _isScanning = false;
  bool _isVerifying = false;
  String? _error;
  String? _successMessage;

  // Getters
  QRCodeModel? get scannedQrCode => _scannedQrCode;
  bool get isScanning => _isScanning;
  bool get isVerifying => _isVerifying;
  String? get error => _error;
  String? get successMessage => _successMessage;

  /// Start scanning
  void startScanning() {
    print('📷 Starting QR scan...');
    _isScanning = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Stop scanning
  void stopScanning() {
    print('⏸️ Stopping QR scan...');
    _isScanning = false;
    notifyListeners();
  }

  /// Handle QR code scan
  Future<bool> handleQrScan(BarcodeCapture capture) async {
    try {
      _isVerifying = true;
      _error = null;
      notifyListeners();

      print('📷 QR Code scanned, processing...');

      // ✅ STEP 1: Parse QR code via service
      final qrCode = _qrService.parseQrCode(capture);
      
      if (qrCode == null) {
        _error = '❌ Invalid QR code format';
        _isVerifying = false;
        notifyListeners();
        return false;
      }

      print('✅ QR parsed - UUID: ${qrCode.uuid}');

      // ✅ STEP 2: Validate QR via service
      if (!_qrService.validateQrCode(qrCode)) {
        _error = '❌ QR code validation failed';
        _isVerifying = false;
        notifyListeners();
        return false;
      }

      // ✅ STEP 3: Fetch location data from Supabase using UUID
      // TODO: Implement Supabase lookup
      // final locationData = await _supabaseService.getLocationByUuid(qrCode.uuid);
      
      // For now, skip geofencing check (will implement after Supabase integration)
      print('⚠️ TODO: Fetch location data from Supabase using UUID: ${qrCode.uuid}');
      
      // ✅ STEP 4: Check location via geofencing service
      // TODO: Uncomment after Supabase integration
      /*
      print('📍 Checking location...');
      final isWithinRange = await _geofencingService.isWithinGeofence(
        targetLat: locationData.latitude,
        targetLng: locationData.longitude,
      );

      if (!isWithinRange) {
        _error = '📍 You are too far from ${locationData.name}';
        _isVerifying = false;
        notifyListeners();
        return false;
      }
      */

      // ✅ STEP 5: SUCCESS (temporary, without geofence check)
      _scannedQrCode = qrCode;
      _successMessage = '✅ QR code scanned successfully!';
      _isVerifying = false;
      _isScanning = false;
      notifyListeners();

      print('✅ QR scan successful!');
      return true;

    } catch (e) {
      print('❌ QR Scan Error: $e');
      _error = '❌ Error: ${e.toString()}';
      _isVerifying = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset state
  void reset() {
    print('🔄 Resetting QR provider state...');
    _scannedQrCode = null;
    _error = null;
    _successMessage = null;
    _isScanning = false;
    _isVerifying = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }
}