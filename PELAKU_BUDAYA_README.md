# Fitur Pelaku Budaya - Sembara

## 📋 Overview
Sistem pelaku budaya memungkinkan user untuk upgrade akun mereka menjadi "Pelaku Budaya" yang dapat mengupload dan showcase hasil kerajinan budaya.

---

## 🎯 Fitur yang Sudah Diimplementasi

### 1. **User Model Enhancement**
**File**: `lib/providers/profile_provider.dart`

**Fields Baru di UserProfile**:
- `isPelakuBudaya: bool` - Status pelaku budaya
- `hideProgress: bool` - Opsi sembunyikan progress bar
- `uploadedKaryaIds: List<String>` - Daftar ID karya yang diupload

**Methods Baru**:
- `upgradeToPelakuBudaya()` - Upgrade user ke pelaku budaya
- `addUploadedKarya(String karyaId)` - Tambah karya yang diupload
- `updateProfile()` - Update dengan parameter tambahan

---

### 2. **Karya Model**
**File**: `lib/models/karya_model.dart`

**Fields**:
- `id, name, creatorId, creatorName` - Identitas karya
- `tag, umkm, description, imageUrl` - Detail karya
- `color, height, iconCodePoint` - Display properties
- `createdAt, likes, views` - Metadata

---

### 3. **Upload Karya Screen**
**File**: `lib/screens/karya/upload_karya_screen.dart`

**Fitur**:
- ✅ Form upload dengan validation
- ✅ Image picker placeholder (TODO: implement actual picker)
- ✅ Tag selection dengan ChoiceChip (6 tags)
- ✅ Dropdown kategori UMKM (6 categories)
- ✅ Text fields untuk nama & deskripsi
- ✅ Integration dengan ProfileProvider

**Tags Available**: Batik, Furniture, Keramik, Anyaman, Tenun, Wayang

**UMKM Categories**: Batik Nusantara, Kerajinan Kayu, Gerabah Tradisional, Anyaman Bambu, Tenun Ikat, Wayang Kulit

---

### 4. **New Profile Screen dengan Tabs**
**File**: `lib/screens/profile/new_profile_screen.dart`

**Struktur**:
- **Header Section**:
  - Avatar dengan mascot icon
  - Display name (editable via dialog)
  - Badge (Pelaku Budaya / Mascot name)
  - Progress bar (dapat disembunyikan)
  - Toggle hide progress (khusus pelaku budaya)
  - Button upgrade (untuk user biasa)

- **Tab 1: Koleksi** (untuk semua user)
  - Grid 3 kolom untuk artifacts
  - Locked/unlocked state

- **Tab 2: Prestasi** (untuk semua user)
  - List achievements dengan status
  - Icon, name, description
  - Visual indicator unlocked

- **Tab 3: Karya Saya** (khusus pelaku budaya)
  - Grid 2 kolom showcase karya
  - Empty state jika belum ada karya
  - FloatingActionButton untuk upload

**Dynamic Tabs**: Tab count berubah otomatis (2 tabs user biasa, 3 tabs pelaku budaya)

---

### 5. **Edit Display Name Dialog**
**File**: `lib/widgets/edit_display_name_dialog.dart`

**Fitur**:
- ✅ Form validation (min 3 characters)
- ✅ Pre-fill dengan nama saat ini
- ✅ Integration dengan ProfileProvider
- ✅ SnackBar confirmation
- ✅ Menggunakan theme system (AppColors, AppTextStyles)

---

### 6. **Upgrade to Pelaku Budaya Dialog**
**File**: `lib/widgets/upgrade_pelaku_budaya_dialog.dart`

**Fitur**:
- ✅ Info benefits menjadi pelaku budaya
- ✅ 4 benefits dengan icons
- ✅ Confirmation flow
- ✅ Integration dengan ProfileProvider
- ✅ Success message dengan emoji

**Benefits**:
1. 📤 Upload hasil karya budaya
2. 👁️ Showcase karya di profil
3. 👥 Terhubung dengan pelaku budaya lain
4. ⭐ Dapatkan apresiasi dari komunitas

---

### 7. **Search User di Karya Screen**
**File**: `lib/screens/karya/karya_screen.dart` (already implemented)

**Fitur Search Existing**:
- ✅ Search by karya name
- ✅ Search by creator/user name (format: "Name - Location")
- ✅ Search by tag
- ✅ Search by UMKM category
- ✅ Tag suggestions

**Cara Search User**:
Ketik nama pelaku budaya di search bar, contoh:
- "Ibu Siti" → Find karya by Ibu Siti - Solo
- "Pak Budi" → Find karya by Pak Budi - Jepara
- "Solo" → Find all karya from Solo location

---

## 🎨 Theme Integration

Semua fitur menggunakan **centralized theme system**:
- `AppColors` - Warna batik branding (batik50-800, dll)
- `AppTextStyles` - Typography consistency
- `AppDimensions` - Spacing & sizing

---

## 🔄 User Flow

### Flow 1: User Biasa → Pelaku Budaya
1. User buka ProfileScreen
2. Lihat button "Jadi Pelaku Budaya"
3. Klik → Dialog muncul dengan benefits
4. Confirm → Status berubah jadi pelaku budaya
5. Tab "Karya Saya" muncul otomatis
6. FloatingActionButton "Upload Karya" tersedia

### Flow 2: Upload Karya
1. Pelaku budaya buka ProfileScreen
2. Tab "Karya Saya" → Klik FAB "Upload Karya"
3. UploadKaryaScreen terbuka
4. Pilih foto (TODO), isi form, pilih tag & UMKM
5. Submit → Karya tersimpan
6. Kembali ke profile → Karya muncul di grid

### Flow 3: Edit Display Name
1. User buka ProfileScreen
2. Klik icon edit (top right)
3. Dialog muncul dengan current name
4. Edit & save → Nama ter-update
5. Success message

### Flow 4: Hide Progress
1. Pelaku budaya buka ProfileScreen
2. Toggle "Sembunyikan Progress"
3. Progress bar hilang dari header
4. Toggle lagi → Progress bar muncul kembali

### Flow 5: Search User
1. User buka KaryaScreen
2. Ketik nama pelaku budaya di search bar
3. Results filtered by creator name
4. Klik karya → Detail

---

## 📝 TODO / Next Steps

### High Priority
1. **Image Picker Implementation**
   - Integrate `image_picker` package
   - Handle image upload to Supabase Storage
   - Add image preview in UploadKaryaScreen

2. **Supabase Integration**
   - Create `karya` table schema
   - Implement CRUD operations
   - Sync uploaded karya dengan profile

3. **Real Karya Data**
   - Replace mock data dengan actual data
   - Fetch from Supabase
   - Display real images

### Medium Priority
4. **Karya Detail Screen**
   - View full karya details
   - Like & comment features
   - Share functionality

5. **User Profile Public View**
   - View other pelaku budaya's profile
   - See their showcase
   - Follow/unfollow feature

6. **Advanced Search**
   - Filter by location
   - Sort by popularity/date
   - Search pelaku budaya directly (dedicated tab?)

### Low Priority
7. **Analytics**
   - Track karya views
   - Track profile visits
   - Popular tags insights

8. **Notifications**
   - Notify when someone likes karya
   - Notify when someone views profile

---

## 🗄️ Database Schema (Proposed)

### Table: `karya`
```sql
CREATE TABLE karya (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID REFERENCES auth.users(id),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  tag TEXT NOT NULL,
  umkm_category TEXT NOT NULL,
  color INTEGER,
  icon_code_point INTEGER,
  likes INTEGER DEFAULT 0,
  views INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Table: `profiles` (update existing)
```sql
ALTER TABLE profiles ADD COLUMN is_pelaku_budaya BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN hide_progress BOOLEAN DEFAULT FALSE;
```

---

## 🧪 Testing Checklist

### User Model
- [ ] Create user with isPelakuBudaya = false
- [ ] Upgrade to pelaku budaya
- [ ] Add karya IDs
- [ ] Toggle hideProgress
- [ ] Update displayName

### Upload Karya
- [ ] Form validation (empty fields)
- [ ] Tag selection
- [ ] UMKM dropdown
- [ ] Submit success
- [ ] Cancel flow

### Profile Screen
- [ ] Render untuk user biasa (2 tabs)
- [ ] Render untuk pelaku budaya (3 tabs)
- [ ] Hide progress toggle works
- [ ] Edit name dialog
- [ ] Upgrade dialog
- [ ] Empty showcase state
- [ ] Showcase dengan karya

### Search
- [ ] Search by karya name
- [ ] Search by creator name
- [ ] Search by tag
- [ ] Search by UMKM
- [ ] Empty search results

---

## 📚 Files Created/Modified

### Created
1. `lib/models/karya_model.dart` - Karya data model
2. `lib/screens/karya/upload_karya_screen.dart` - Upload form
3. `lib/screens/profile/new_profile_screen.dart` - Profile dengan tabs
4. `lib/widgets/edit_display_name_dialog.dart` - Edit name dialog
5. `lib/widgets/upgrade_pelaku_budaya_dialog.dart` - Upgrade dialog

### Modified
1. `lib/providers/profile_provider.dart` - Added pelaku budaya fields & methods
2. `lib/screens/karya/karya_screen.dart` - Already has search by creator

---

## 💡 Usage Examples

### Check if User is Pelaku Budaya
```dart
final profileProvider = Provider.of<ProfileProvider>(context);
if (profileProvider.profile?.isPelakuBudaya == true) {
  // Show upload button
}
```

### Update Display Name
```dart
await profileProvider.updateProfile(displayName: 'Nama Baru');
```

### Upgrade to Pelaku Budaya
```dart
await profileProvider.upgradeToPelakuBudaya();
```

### Add Uploaded Karya
```dart
profileProvider.addUploadedKarya('karya_id_123');
```

### Toggle Hide Progress
```dart
await profileProvider.updateProfile(hideProgress: true);
```

---

**Status**: ✅ All features implemented (frontend only)
**Next**: Backend integration dengan Supabase
