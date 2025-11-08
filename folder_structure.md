# BudayaGo - Folder Structure Documentation

## 📋 Table of Contents
- [Overview](#overview)
- [Why Hybrid Layer-First?](#why-hybrid-layer-first)
- [Folder Structure](#folder-structure)
- [Detailed Explanation](#detailed-explanation)
- [Best Practices](#best-practices)
- [Examples](#examples)

---

## 🎯 Overview

BudayaGo menggunakan **Hybrid Layer-First Architecture** - kombinasi antara layer-based organization dengan feature grouping.

### Quick Info
- **Team Size**: 5 developers
- **Project Type**: Medium-scale mobile app
- **State Management**: Provider
- **Backend**: Supabase (Auth, Database, Storage)

---

## 🤔 Why Hybrid Layer-First?

### Keuntungan untuk Tim Kita:

✅ **Easy Collaboration (5 orang)**
- Setiap developer bisa fokus ke feature tertentu
- Minimal merge conflict
- Clear ownership per feature

✅ **Flexible for Changes**
- Planning belum matang? No problem!
- Mudah add/remove/modify features
- Refactoring lebih simple

✅ **Beginner Friendly**
- Struktur jelas & predictable
- Mudah onboarding member baru
- Tidak overwhelmed dengan banyak layer

✅ **Scalable**
- Bisa grow sampai 50-100 screens
- Feature terorganisir dengan baik
- Easy maintenance

### Perbandingan dengan Arsitektur Lain:

| Aspek | Pure Layer-First | **Hybrid Layer-First** | Feature-First |
|-------|------------------|----------------------|---------------|
| Complexity | Low | **Medium** | High |
| Scalability | Poor (>20 screens) | **Good (up to 100)** | Excellent |
| Team Size | 1-2 | **3-10** | 10+ |
| Learning Curve | Easy | **Easy** | Steep |
| Flexibility | Low | **High** | Medium |
| Our Case | ❌ | ✅ **Perfect** | ❌ Overkill |

---

## 📁 Folder Structure

```
budayago/
├── lib/
│   ├── config/                     # App configuration
│   │   ├── supabase_config.dart
│   │   └── app_config.dart
│   │
│   ├── models/                     # Data models
│   │   ├── user_model.dart
│   │   ├── budaya_model.dart
│   │   ├── booking_model.dart
│   │   └── review_model.dart
│   │
│   ├── providers/                  # State management (Provider)
│   │   ├── auth_provider.dart
│   │   ├── budaya_provider.dart
│   │   ├── booking_provider.dart
│   │   └── theme_provider.dart
│   │
│   ├── services/                   # Business logic & API calls
│   │   ├── auth_service.dart
│   │   ├── budaya_service.dart
│   │   ├── booking_service.dart
│   │   └── supabase_service.dart
│   │
│   ├── screens/                    # UI Screens (grouped by feature)
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── widgets/           # Auth-specific widgets
│   │   │       ├── auth_button.dart
│   │   │       ├── social_login_button.dart
│   │   │       └── auth_text_field.dart
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── home_banner.dart
│   │   │       ├── category_section.dart
│   │   │       └── featured_budaya_card.dart
│   │   │
│   │   ├── budaya/
│   │   │   ├── budaya_list_screen.dart
│   │   │   ├── budaya_detail_screen.dart
│   │   │   ├── budaya_search_screen.dart
│   │   │   ├── budaya_filter_screen.dart
│   │   │   └── widgets/
│   │   │       ├── budaya_card.dart
│   │   │       ├── budaya_image_slider.dart
│   │   │       ├── budaya_info_section.dart
│   │   │       └── budaya_review_card.dart
│   │   │
│   │   ├── booking/
│   │   │   ├── booking_screen.dart
│   │   │   ├── booking_detail_screen.dart
│   │   │   ├── booking_history_screen.dart
│   │   │   ├── payment_screen.dart
│   │   │   └── widgets/
│   │   │       ├── booking_card.dart
│   │   │       ├── booking_form.dart
│   │   │       ├── payment_method_tile.dart
│   │   │       └── booking_status_badge.dart
│   │   │
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       ├── edit_profile_screen.dart
│   │       ├── settings_screen.dart
│   │       └── widgets/
│   │           ├── profile_header.dart
│   │           └── settings_tile.dart
│   │
│   ├── widgets/                    # Shared/Common widgets
│   │   ├── common_button.dart
│   │   ├── common_card.dart
│   │   ├── common_text_field.dart
│   │   ├── loading_widget.dart
│   │   ├── empty_state.dart
│   │   ├── error_widget.dart
│   │   └── custom_app_bar.dart
│   │
│   ├── utils/                      # Helper functions & utilities
│   │   ├── constants.dart
│   │   ├── validators.dart
│   │   ├── date_helper.dart
│   │   ├── string_helper.dart
│   │   └── image_helper.dart
│   │
│   ├── theme/                      # App theming
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_theme.dart
│   │   └── app_dimensions.dart
│   │
│   └── main.dart                   # Entry point
│
├── assets/                         # Asset files
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/                           # Unit & widget tests
│
│
├── pubspec.yaml
└── README.md
```

---

## 📖 Detailed Explanation

### 1. **config/** - Configuration Files
**Purpose**: Menyimpan konfigurasi app (API keys, endpoints, constants)

```dart
// supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_URL';
  static const String supabaseAnonKey = 'YOUR_KEY';
}
```

**When to use**: Setup awal app, environment variables

---

### 2. **models/** - Data Models
**Purpose**: Representasi data/struktur object

```dart
// budaya_model.dart
class BudayaModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  
  BudayaModel({...});
  
  factory BudayaModel.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

**When to use**: 
- Data dari API
- Data dari database
- Data yang di-pass antar screens

---

### 3. **providers/** - State Management
**Purpose**: Manage app state dengan Provider pattern

```dart
// budaya_provider.dart
class BudayaProvider extends ChangeNotifier {
  List<BudayaModel> _budayaList = [];
  
  List<BudayaModel> get budayaList => _budayaList;
  
  Future<void> fetchBudaya() async {
    // Fetch data
    notifyListeners();
  }
}
```

**When to use**:
- Data yang perlu di-share ke banyak screens
- Authentication state
- Theme state
- Shopping cart, favorites, etc

---

### 4. **services/** - Business Logic & API
**Purpose**: Handle API calls, business logic, database operations

```dart
// budaya_service.dart
class BudayaService {
  final _supabase = Supabase.instance.client;
  
  Future<List<BudayaModel>> fetchBudaya() async {
    final response = await _supabase.from('budaya').select();
    return response.map((e) => BudayaModel.fromJson(e)).toList();
  }
}
```

**When to use**:
- API calls
- Database queries
- Complex business logic

---

### 5. **screens/** - UI Screens (Feature Grouped)
**Purpose**: Semua halaman app, dikelompokkan berdasarkan feature

#### Structure per Feature:
```
feature_name/
├── feature_screen.dart        # Main screen
├── feature_detail_screen.dart # Detail screen
└── widgets/                   # Feature-specific widgets
    └── feature_widget.dart
```

**Example - Budaya Feature**:
```
budaya/
├── budaya_list_screen.dart      # List semua budaya
├── budaya_detail_screen.dart    # Detail 1 budaya
├── budaya_search_screen.dart    # Search budaya
└── widgets/
    ├── budaya_card.dart         # Card untuk display budaya
    └── budaya_filter_chip.dart  # Filter chips
```

**When to use**:
- Setiap halaman baru
- Widget yang HANYA dipakai di feature tertentu

---

### 6. **widgets/** - Shared/Common Widgets
**Purpose**: Reusable widgets yang dipakai di BANYAK feature

```dart
// common_button.dart
class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  // Widget yang bisa dipakai dimana aja
}
```

**When to use**:
- Button yang design-nya sama di semua screen
- Card template yang generic
- Loading indicator
- Empty state
- Error widget

**❗ Rule**: Kalau widget cuma dipakai di 1 feature → taruh di `screens/feature/widgets/`

---

### 7. **utils/** - Helper Functions
**Purpose**: Function-function helper yang sering dipakai

```dart
// validators.dart
class Validators {
  static String? validateEmail(String? value) {
    // Email validation logic
  }
}

// date_helper.dart
class DateHelper {
  static String formatDate(DateTime date) {
    // Format date logic
  }
}
```

**When to use**:
- Form validation
- Date formatting
- String manipulation
- Image processing

---

### 8. **theme/** - App Theming
**Purpose**: Styling & theming app

```dart
// app_colors.dart
class AppColors {
  static const primary = Color(0xFF6200EE);
  static const secondary = Color(0xFF03DAC6);
}

// app_text_styles.dart
class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
}
```

**When to use**:
- Define colors
- Text styles
- Spacing constants
- Border radius

---

## 💡 Best Practices

### 1. **File Naming Convention**
```
✅ GOOD:
- budaya_list_screen.dart
- booking_card.dart
- auth_provider.dart

❌ BAD:
- BudayaListScreen.dart
- bookingCard.dart
- Auth_Provider.dart
```

### 2. **Import Organization**
```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:provider/provider.dart';

// 4. Local imports
import '../models/budaya_model.dart';
import '../providers/budaya_provider.dart';
```

### 3. **Widget Placement**
```
❓ Widget cuma dipakai di Budaya feature?
   → taruh di screens/budaya/widgets/

❓ Widget dipakai di >2 features?
   → taruh di widgets/

❓ Masih ragu?
   → Mulai di screens/feature/widgets/
   → Kalau ternyata dipakai di tempat lain, baru pindah ke widgets/
```

### 4. **Provider Scope**
```dart
// ✅ GOOD: Provider yang banyak dipakai
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
)

// ⚠️ OK: Provider untuk specific screen
ChangeNotifierProvider(
  create: (_) => BudayaDetailProvider(),
  child: BudayaDetailScreen(),
)
```

---

## 📝 Examples

### Example 1: Menambah Feature Baru (Review)

**Step 1**: Buat model
```dart
// lib/models/review_model.dart
class ReviewModel {
  final String id;
  final String budayaId;
  final String userId;
  final double rating;
  final String comment;
}
```

**Step 2**: Buat service
```dart
// lib/services/review_service.dart
class ReviewService {
  Future<List<ReviewModel>> fetchReviews(String budayaId) async {
    // Fetch from Supabase
  }
}
```

**Step 3**: Buat provider (kalau perlu)
```dart
// lib/providers/review_provider.dart
class ReviewProvider extends ChangeNotifier {
  List<ReviewModel> _reviews = [];
  // ... provider logic
}
```

**Step 4**: Buat screens & widgets
```
lib/screens/review/
├── review_list_screen.dart
├── add_review_screen.dart
└── widgets/
    ├── review_card.dart
    └── rating_stars.dart
```

---

### Example 2: Collaboration Scenario

**Tim 5 orang, pembagian tugas:**

**Person 1 - Auth Feature**
```
screens/auth/
providers/auth_provider.dart
services/auth_service.dart
```

**Person 2 - Budaya Feature**
```
screens/budaya/
providers/budaya_provider.dart
services/budaya_service.dart
```

**Person 3 - Booking Feature**
```
screens/booking/
providers/booking_provider.dart
services/booking_service.dart
```

**Person 4 - Profile Feature**
```
screens/profile/
models/user_model.dart
```

**Person 5 - Shared Components**
```
widgets/
theme/
utils/
```

**Result**: ✅ Minimal merge conflicts!

---

### Example 3: Refactoring Scenario

**Scenario**: Mau pindah dari Provider ke Riverpod

**What to change**:
```
✅ providers/ → Ganti semua provider
✅ main.dart → Ganti ProviderScope
```

**What stays same**:
```
✅ screens/ → Tidak perlu ubah (cuma import berubah)
✅ models/ → Tetap sama
✅ services/ → Tetap sama
✅ widgets/ → Tetap sama
```

**Result**: Easy refactoring! 🎉

---

## 🎯 Summary

### Key Points:
1. **Hybrid Layer-First** = Layer organization + Feature grouping
2. **Screens grouped by feature** = Easy navigation & collaboration
3. **Clear separation of concerns** = Maintainable code
4. **Flexible for changes** = Perfect untuk planning belum matang
5. **Scalable** = Bisa grow dengan app

### When to Refactor:
- ✅ App > 100 screens → Consider Feature-First
- ✅ Team > 10 people → Consider Feature-First
- ✅ Need strict module boundaries → Consider Feature-First

### For Now:
**Stick with Hybrid Layer-First** - It's perfect for our needs! 🚀

---

## 📚 References
- [Flutter Project Structure](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)
- [Provider Package](https://pub.dev/packages/provider)
- [Supabase Flutter](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)

---

**Last Updated**: November 2025  
**Team**: BudayaGo Development Team