import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/geofencing_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/custom_app_bar.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController cameraController;
  final GeofencingService _geofencingService = GeofencingService();
  bool isScanned = false;
  bool isProcessing = false;

  bool isCameraPermissionGranted = false;
  bool isLocationPermissionGranted = false;
  bool isCheckingPermission = true;

  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _checkAllPermissions();
  }

  void _initCamera() {
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      // ✅ TAMBAH INI: Auto start false
      autoStart: false,
    );
  }

  // ✅ START CAMERA SETELAH PERMISSION GRANTED
  Future<void> _startCamera() async {
    try {
      print('📷 Starting camera...');
      await cameraController.start();
      print('✅ Camera started');
    } catch (e) {
      print('❌ Error starting camera: $e');
    }
  }

  Future<void> _checkAllPermissions() async {
    setState(() => isCheckingPermission = true);

    try {
      print('🔍 Checking permissions...');

      // 1. Check Camera Permission
      var cameraStatus = await Permission.camera.status;
      print('📷 Camera status: $cameraStatus');

      if (cameraStatus.isDenied) {
        print('⚠️ Camera denied, requesting...');
        cameraStatus = await Permission.camera.request();
        print('📷 After request: $cameraStatus');
      }

      if (cameraStatus.isPermanentlyDenied) {
        setState(() => isCheckingPermission = false);
        _showPermissionDialog(
          icon: Icons.camera_alt_outlined,
          title: '📷 Izin Kamera Diblokir',
          message:
              'Izin kamera telah diblokir secara permanen.\n\nSilakan aktifkan di:\nPengaturan > Aplikasi > BudayaGo > Izin > Kamera',
          canRetry: false,
          showSettingsButton: true,
        );
        return;
      }

      if (!cameraStatus.isGranted) {
        setState(() => isCheckingPermission = false);
        _showPermissionDialog(
          icon: Icons.camera_alt_outlined,
          title: '📷 Izin Kamera Diperlukan',
          message: 'Aplikasi membutuhkan akses kamera untuk scan QR code.',
          canRetry: true,
          showSettingsButton: false,
        );
        return;
      }

      setState(() => isCameraPermissionGranted = true);
      print('✅ Camera permission granted');

      // 2. Check Location Permission
      var locationStatus = await Permission.location.status;
      print('📍 Location status: $locationStatus');

      if (locationStatus.isDenied) {
        print('⚠️ Location denied, requesting...');
        locationStatus = await Permission.location.request();
        print('📍 After request: $locationStatus');
      }

      if (locationStatus.isPermanentlyDenied) {
        setState(() => isCheckingPermission = false);
        _showPermissionDialog(
          icon: Icons.location_off,
          title: '📍 Izin Lokasi Diblokir',
          message:
              'Izin lokasi telah diblokir secara permanen.\n\nSilakan aktifkan di:\nPengaturan > Aplikasi > BudayaGo > Izin > Lokasi',
          canRetry: false,
          showSettingsButton: true,
        );
        return;
      }

      if (!locationStatus.isGranted) {
        setState(() => isCheckingPermission = false);
        _showPermissionDialog(
          icon: Icons.location_off,
          title: '📍 Izin Lokasi Diperlukan',
          message:
              'Aplikasi membutuhkan akses lokasi untuk memverifikasi bahwa Anda berada di lokasi wisata yang benar.',
          canRetry: true,
          showSettingsButton: false,
        );
        return;
      }

      setState(() => isLocationPermissionGranted = true);
      print('✅ Location permission granted');

      // 3. All permissions granted!
      setState(() => isCheckingPermission = false);
      print('🎉 All permissions granted!');

      // ✅ START CAMERA SETELAH PERMISSION GRANTED
      await _startCamera();
    } catch (e) {
      print('❌ Error checking permissions: $e');
      setState(() => isCheckingPermission = false);
      _showPermissionDialog(
        icon: Icons.error_outline,
        title: '❌ Error',
        message: 'Terjadi kesalahan saat memeriksa izin:\n$e',
        canRetry: true,
        showSettingsButton: false,
      );
    }
  }

  void _showPermissionDialog({
    required IconData icon,
    required String title,
    required String message,
    required bool canRetry,
    required bool showSettingsButton,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: AppColors.warning, size: AppDimensions.iconL),
                SizedBox(width: AppDimensions.spaceS),
                Expanded(child: Text(title, style: AppTextStyles.h6)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                SizedBox(height: AppDimensions.spaceM),
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: AppDimensions.iconS,
                      ),
                      SizedBox(width: AppDimensions.spaceXS),
                      Expanded(
                        child: Text(
                          'Fitur ini memastikan Anda berada di lokasi wisata yang benar sebelum melakukan check-in.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (!canRetry)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Kembali'),
                ),
              if (showSettingsButton)
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Buka Pengaturan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (canRetry)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
              if (canRetry)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _checkAllPermissions();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ LOADING STATE
    if (isCheckingPermission) {
      return Scaffold(
        appBar: const CustomGradientAppBar(
          title: 'Scan QR Code',
          showBackButton: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memeriksa izin...'),
            ],
          ),
        ),
      );
    }

    // ✅ PERMISSION NOT GRANTED STATE
    if (!isCameraPermissionGranted || !isLocationPermissionGranted) {
      return Scaffold(
        appBar: const CustomGradientAppBar(
          title: 'Scan QR Code',
          showBackButton: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  !isCameraPermissionGranted
                      ? Icons.camera_alt_outlined
                      : Icons.location_off,
                  size: AppDimensions.iconXL * 1.67, // 80px
                  color: AppColors.error.withOpacity(0.6),
                ),
                SizedBox(height: AppDimensions.spaceL),
                Text(
                  !isCameraPermissionGranted
                      ? 'Izin Kamera Diperlukan'
                      : 'Izin Lokasi Diperlukan',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spaceS),
                Text(
                  !isCameraPermissionGranted
                      ? 'Aplikasi membutuhkan akses kamera untuk scan QR code.'
                      : 'Aplikasi membutuhkan akses lokasi untuk memverifikasi bahwa Anda berada di lokasi wisata yang benar.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spaceXL),
                ElevatedButton.icon(
                  onPressed: _checkAllPermissions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Izinkan Akses'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingS,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spaceS),
                TextButton.icon(
                  onPressed: () async {
                    await openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Buka Pengaturan'),
                ),
                SizedBox(height: AppDimensions.spaceS),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ SCANNER ACTIVE STATE (Permission granted)
    return Scaffold(
      appBar: CustomGradientAppBar(
        title: 'Scan QR Code',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: AppDimensions.iconXL * 1.67,
                      color: AppColors.error,
                    ),
                    SizedBox(height: AppDimensions.spaceM),
                    Text('Error Kamera', style: AppTextStyles.h5),
                    SizedBox(height: AppDimensions.spaceXS),
                    Text(
                      error.errorDetails?.message ?? 'Gagal membuka kamera',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    SizedBox(height: AppDimensions.spaceM),
                    ElevatedButton(
                      onPressed: () async {
                        // ✅ FIX: Stop dulu sebelum restart
                        try {
                          await cameraController.stop();
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                          await cameraController.start();
                        } catch (e) {
                          print('❌ Error restarting camera: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal restart kamera: $e')),
                          );
                        }
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            },
            onDetect: (capture) {
              final now = DateTime.now();
              if (_lastScanTime != null &&
                  now.difference(_lastScanTime!).inSeconds < 3) {
                return;
              }

              if (!isScanned && !isProcessing) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    print('🔍 QR Code Scanned: "${barcode.rawValue}"');
                    setState(() {
                      isScanned = true;
                      _lastScanTime = now;
                    });
                    _handleQRCode(barcode.rawValue!);
                    break;
                  }
                }
              }
            },
          ),
          CustomPaint(
            painter: ScannerOverlay(),
            child: const SizedBox.expand(),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.overlay,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  'Arahkan kamera ke QR Code',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQRCode(String qrCode) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final position = await _geofencingService.getCurrentLocation();

      if (position == null) {
        if (!mounted) return;
        Navigator.pop(context);
        await _showErrorDialog(
          '❌ Gagal Mendapatkan Lokasi',
          'Pastikan GPS aktif dan izin lokasi sudah diberikan',
        );
        _resetScanState();
        return;
      }

      final result = await _geofencingService.validateQRCode(
        qrString: qrCode,
        userPosition: position,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['valid']) {
        _showSuccessDialog(result);
      } else {
        String title;
        switch (result['error']) {
          case 'INVALID_PREFIX':
            title = '❌ QR Code Tidak Valid';
            break;
          case 'INVALID_FORMAT':
            title = '❌ Format QR Rusak';
            break;
          case 'UNSUPPORTED_VERSION':
            title = '⚠️ Versi Tidak Didukung';
            break;
          case 'LOCATION_NOT_FOUND':
            title = '❌ Lokasi Tidak Ditemukan';
            break;
          case 'OUT_OF_RANGE':
            title = '📍 Lokasi Terlalu Jauh';
            break;
          default:
            title = '❌ Error';
        }

        await _showErrorDialog(
          title,
          result['message'],
          details:
              result['error'] == 'OUT_OF_RANGE'
                  ? 'Jarak Anda: ${result['distance'].toStringAsFixed(0)} meter\n'
                      'Maksimal: ${result['radius']} meter'
                  : result['details'],
        );
        _resetScanState();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      await _showErrorDialog('❌ Error', 'Terjadi kesalahan: $e');
      _resetScanState();
    }
  }

  void _resetScanState() {
    if (mounted) {
      setState(() {
        isProcessing = false;
        isScanned = false;
      });
    }
  }

  Future<void> _showErrorDialog(
    String title,
    String message, {
    String? details,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.error.withOpacity(0.8), AppColors.error],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 50,
                            color: AppColors.background,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceM),
                        Text(
                          title,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    padding: EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (details != null) ...[
                          SizedBox(height: AppDimensions.spaceM),
                          Container(
                            padding: EdgeInsets.all(AppDimensions.paddingS),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusS,
                              ),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                                SizedBox(width: AppDimensions.spaceXS),
                                Expanded(
                                  child: Text(
                                    details,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceL),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close_rounded, color: AppColors.error),
                        label: Text(
                          'Tutup',
                          style: TextStyle(color: AppColors.error),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingL),
                ],
              ),
            ),
          ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    if (!mounted) return;

    // Note: XP reward akan diberikan oleh caller (home_screen)
    // setelah dialog ditutup untuk menghindari duplikasi

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.orangePinkGradient,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 50,
                            color: AppColors.background,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceM),
                        Text(
                          '🎉 Selamat!',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceXS),
                        Text(
                          'Kamu telah berhasil mengunjungi',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.background.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    padding: EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppDimensions.paddingXS),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.orangePinkGradient,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                              ),
                              child: Icon(
                                Icons.location_on,
                                size: 20,
                                color: AppColors.background,
                              ),
                            ),
                            SizedBox(width: AppDimensions.spaceS),
                            Expanded(
                              child: Text(
                                result['locationName'],
                                style: AppTextStyles.h5.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (result['description'] != null &&
                            result['description'].toString().isNotEmpty) ...[
                          SizedBox(height: AppDimensions.spaceS),
                          Text(
                            result['description'],
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: AppDimensions.spaceM),
                        Container(
                          padding: EdgeInsets.all(AppDimensions.paddingM),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.orangePinkGradient,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                color: AppColors.background,
                                size: 24,
                              ),
                              SizedBox(width: AppDimensions.spaceS),
                              Text(
                                '+50 XP',
                                style: AppTextStyles.h5.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceL),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context, result);
                        },
                        icon: Icon(
                          Icons.home_rounded,
                          color: AppColors.batik700,
                        ),
                        label: Text(
                          'Kembali ke Home',
                          style: TextStyle(
                            color: AppColors.batik700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingL),
                ],
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    final cutOutPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(
        RRect.fromRectAndRadius(
          scanArea,
          Radius.circular(AppDimensions.radiusM),
        ),
      ),
    );

    canvas.drawPath(cutOutPath, Paint()..color = AppColors.overlay);

    final paint =
        Paint()
          ..color = AppColors.secondary
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + cornerLength, scanArea.top),
      paint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left, scanArea.top + cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right - cornerLength, scanArea.top),
      paint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + cornerLength, scanArea.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left, scanArea.bottom - cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom),
      Offset(scanArea.right - cornerLength, scanArea.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
