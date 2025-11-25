# 🔄 QR Code Flow - BudayaGo System

Dokumentasi proses encoding dan decoding QR code.

---

## 🎯 Overview

BudayaGo menggunakan QR code untuk check-in di lokasi wisata budaya.

### Format QR Code:
```
SEMBARA-o2o:eyJVVUlEIjoibG9jYXRpb24taWQiLCJ2IjoxfQ==
```

**Components**:
- `SEMBARA-o2o` - Prefix
- `:` - Separator
- `eyJVVU...` - Base64 encoded JSON

### JSON Structure (Decoded):
```json
{
  "UUID": "candi-borobudur-001",
  "v": 1
}
```

---

## 🔐 Encoding Flow

```
UUID String 
    ↓
Create JSON Object
    ↓
Convert to JSON String
    ↓
Encode to UTF-8 Bytes
    ↓
Encode to Base64
    ↓
Add Prefix
    ↓
Generate QR Image
```

### Contoh:
```
"candi-borobudur-001"
    ↓
{"UUID":"candi-borobudur-001","v":1}
    ↓
'{"UUID":"candi-borobudur-001","v":1}'
    ↓
[123, 34, 85, 85, 73, 68, ...]
    ↓
eyJVVUlEIjoiY2FuZGktYm9yb2J1ZHVyLTAwMSIsInYiOjF9
    ↓
SEMBARA-o2o:eyJVVUlEIjoiY2FuZGktYm9yb2J1ZHVyLTAwMSIsInYiOjF9
    ↓
[QR Code Image]
```

---

## 🔓 Decoding Flow

```
Scanned QR Code
    ↓
Extract Raw String
    ↓
Split by Separator ':'
    ↓
Validate Prefix
    ↓
Decode Base64
    ↓
Decode UTF-8
    ↓
Parse JSON
    ↓
Create Model Object
    ↓
Validate Data
```

### Contoh:
```
[QR Code Scan]
    ↓
"SEMBARA-o2o:eyJVVUlEIjoiY2FuZGktYm9yb2J1ZHVyLTAwMSIsInYiOjF9"
    ↓
["SEMBARA-o2o", "eyJVVUlEIjoiY2FuZGktYm9yb2J1ZHVyLTAwMSIsInYiOjF9"]
    ↓
✅ Prefix valid
    ↓
[123, 34, 85, 85, 73, 68, ...]
    ↓
'{"UUID":"candi-borobudur-001","v":1}'
    ↓
{"UUID": "candi-borobudur-001", "v": 1}
    ↓
QRCodeModel(uuid: "candi-borobudur-001", version: 1)
    ↓
✅ Valid
```

---

## 💻 Contoh Penggunaan

### 1. Generate QR Code

```dart
final qrService = QrService();

// Generate QR data string
final qrData = qrService.generateQrCodeData(
  uuid: 'candi-borobudur-001',
  version: 1,
);

print(qrData);
// Output: SEMBARA-o2o:eyJVVUlEIjoiY2FuZGktYm9yb2J1ZHVyLTAwMSIsInYiOjF9
```

---

### 2. Scan QR Code

```dart
final qrService = QrService();

// Scan QR code
controller.barcodes.listen((capture) {
  final qrCode = qrService.parseQrCode(capture);
  
  if (qrCode != null && qrService.validateQrCode(qrCode)) {
    print('Valid! UUID: ${qrCode.uuid}');
    // Lanjut ke check-in
  }
});
```

---

### 3. Manual Encode/Decode

```dart
// ENCODING
final qrCode = QRCodeModel(uuid: 'test-123', version: 1);
final encoded = qrCode.encode();
print(encoded);
// SEMBARA-o2o:eyJVVUlEIjoidGVzdC0xMjMiLCJ2IjoxfQ==

// DECODING
final decoded = QRCodeModel.decode(qrString: encoded);
print(decoded.uuid); // test-123
```

---

## ⚠️ Error Handling

### Jenis Error:

1. **QRCodeFormatException** - Format QR salah
2. **QRCodePrefixException** - Prefix tidak sesuai
3. **QRCodeVersionException** - Versi tidak didukung
4. **FormatException** - Base64/JSON rusak

### Contoh Handling:

```dart
try {
  final qrCode = QRCodeModel.decode(qrString: scannedString);
  
  if (!qrService.validateQrCode(qrCode)) {
    showError('QR code tidak valid');
  }
  
} on QRCodePrefixException catch (e) {
  showError('Ini bukan QR code BudayaGo');
} on QRCodeFormatException catch (e) {
  showError('Format QR code salah');
} catch (e) {
  showError('Terjadi kesalahan: $e');
}
```

---

## 📚 File Terkait

- `lib/config/qr_config.dart` - Konfigurasi QR
- `lib/models/qr_code_model.dart` - Model data QR
- `lib/services/qr_service.dart` - Logic encode/decode
- `lib/screens/qr/qr_scanner_screen.dart` - UI scanner

---


