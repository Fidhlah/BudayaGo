# Widgets Documentation

## 📦 Shared Widgets (`lib/widgets/`)

Widget-widget ini dapat digunakan di **semua feature** dalam aplikasi.

### 1. `common_button.dart`
Tombol yang dapat disesuaikan dengan berbagai keperluan.

**Usage:**
```dart
CommonButton(
  text: 'Login',
  onPressed: () => handleLogin(),
  icon: Icons.login,
  isLoading: isLoading,
)
```

**Properties:**
- `text`: Teks tombol (required)
- `onPressed`: Callback saat tombol ditekan
- `isLoading`: Tampilkan loading indicator
- `icon`: Icon di sebelah kiri teks
- `backgroundColor`: Warna background custom
- `textColor`: Warna teks custom
- `width`: Lebar tombol (default: full width)
- `height`: Tinggi tombol (default: AppDimensions.buttonHeightM)

---

### 2. `common_text_field.dart`
Text field dengan styling konsisten.

**Usage:**
```dart
CommonTextField(
  controller: emailController,
  labelText: 'Email',
  hintText: 'your.email@example.com',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value == null ? 'Required' : null,
)
```

**Properties:**
- `controller`: TextEditingController
- `labelText`: Label untuk field
- `hintText`: Placeholder text
- `prefixIcon`: Icon di sebelah kiri
- `suffixIcon`: Widget di sebelah kanan (e.g., password visibility)
- `keyboardType`: Tipe keyboard
- `obscureText`: Sembunyikan teks (untuk password)
- `validator`: Fungsi validasi
- `onChanged`: Callback saat teks berubah
- `maxLines`: Jumlah baris (default: 1)
- `enabled`: Enable/disable field

---

### 3. `loading_widget.dart`
Widget untuk menampilkan loading state.

**Usage:**
```dart
LoadingWidget(
  message: 'Memuat data...',
  color: AppColors.primary,
)
```

**Properties:**
- `message`: Pesan loading (optional)
- `color`: Warna loading indicator (default: AppColors.primary)

---

### 4. `empty_state.dart`
Widget untuk menampilkan empty state.

**Usage:**
```dart
EmptyState(
  icon: Icons.inbox,
  title: 'Belum Ada Data',
  message: 'Data akan muncul di sini setelah Anda menambahkannya',
  action: ElevatedButton(
    onPressed: () => addData(),
    child: Text('Tambah Data'),
  ),
)
```

**Properties:**
- `icon`: Icon untuk empty state (required)
- `title`: Judul (required)
- `message`: Pesan tambahan (optional)
- `action`: Widget action button (optional)

---

### 5. `error_widget.dart`
Widget untuk menampilkan error state.

**Usage:**
```dart
CommonErrorWidget(
  message: 'Gagal memuat data. Periksa koneksi internet Anda.',
  onRetry: () => fetchData(),
)
```

**Properties:**
- `message`: Pesan error (required)
- `onRetry`: Callback untuk retry (optional)

---

## 📁 Feature-Specific Widgets

Widget yang **hanya digunakan di satu feature** harus diletakkan di folder `widgets/` di dalam feature tersebut.

### Contoh Struktur:
```
lib/screens/
├── auth/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── widgets/              # ✅ Auth-specific widgets
│       ├── auth_button.dart
│       ├── social_login_button.dart
│       └── auth_text_field.dart
│
├── home/
│   ├── home_screen.dart
│   └── widgets/              # ✅ Home-specific widgets
│       ├── home_banner.dart
│       ├── category_section.dart
│       └── featured_card.dart
```

---

## 🎯 Decision Tree: Dimana Taruh Widget?

```
Widget ini dipakai di berapa feature?
│
├─ Dipakai di ≥2 feature
│  └─ ✅ Taruh di lib/widgets/
│
└─ Dipakai di 1 feature saja
   └─ ✅ Taruh di lib/screens/[feature]/widgets/
```

---

## 📝 Best Practices

1. **Reusability**: Shared widgets harus generic dan flexible
2. **Naming**: Gunakan prefix yang jelas (e.g., `Common`, `Auth`, `Home`)
3. **Documentation**: Tambahkan comment untuk menjelaskan usage
4. **Consistency**: Ikuti theme dan styling yang sudah ada
5. **Testing**: Test widget di berbagai kondisi

---

**Last Updated**: November 2025  
**Team**: BudayaGo Development Team
