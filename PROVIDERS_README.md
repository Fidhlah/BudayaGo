# Provider State Management - Sembara

## ✅ Providers yang Sudah Dibuat

### 1. **HomeProvider**
**File:** `lib/providers/home_provider.dart`

**Fungsi:**
- Manage user XP (Experience Points)
- Manage user level
- Auto level-up saat XP mencapai threshold
- Track progress to next level

**Methods:**
- `initializeUserData()` - Load initial data
- `claimXP(int xp)` - Tambah XP dan auto level up
- `resetProgress()` - Reset XP dan level
- `setProgress(int xp, int level)` - Set manual untuk testing

**Usage:**
```dart
// Di widget
final homeProvider = Provider.of<HomeProvider>(context);

// Claim XP
homeProvider.claimXP(15);

// Display
Text('Level ${homeProvider.userLevel}');
Text('XP: ${homeProvider.userXP}/${homeProvider.xpForNextLevel}');
```

---

### 2. **ProfileProvider**
**File:** `lib/providers/profile_provider.dart`

**Fungsi:**
- Manage user profile data
- Handle collectibles (items yang sudah dikumpulkan)
- Sync dengan backend (Supabase - TODO)
- Track user stats

**Models:**
- `UserProfile` - Data user (id, email, displayName, mascot, xp, level)
- `Collectible` - Item yang sudah dikumpulkan

**Methods:**
- `loadProfile(String userId)` - Load profile dari backend
- `updateProfile({displayName, mascot})` - Update profile
- `updateProgress(int xp, int level)` - Sync XP/level
- `loadCollectibles()` - Load collectibles
- `addCollectible(Collectible item)` - Tambah collectible baru
- `clear()` - Clear saat logout

**Usage:**
```dart
// Load profile
await profileProvider.loadProfile(userId);

// Display
Text(profileProvider.profile?.displayName ?? 'Guest');
Text('Mascot: ${profileProvider.profile?.mascot}');
Text('Total Collectibles: ${profileProvider.totalCollectibles}');
```

---

### 3. **ChatbotProvider**
**File:** `lib/providers/chatbot_provider.dart`

**Fungsi:**
- Manage chat messages
- Handle AI conversation (mock untuk sekarang)
- Save/load chat history
- Support different mascots

**Models:**
- `ChatMessage` - Single chat message
- `MessageRole` - Enum (user, assistant, system)

**Methods:**
- `initialize(String mascot)` - Init dengan mascot tertentu
- `sendMessage(String content)` - Kirim pesan ke AI
- `loadChatHistory()` - Load history dari storage
- `saveChatHistory()` - Save history
- `clearChat()` - Clear semua chat
- `deleteMessage(String id)` - Hapus message tertentu

**Usage:**
```dart
// Initialize
chatbotProvider.initialize('Garuda');

// Send message
await chatbotProvider.sendMessage('Apa itu batik?');

// Display messages
ListView.builder(
  itemCount: chatbotProvider.messages.length,
  itemBuilder: (context, index) {
    final message = chatbotProvider.messages[index];
    return ChatBubble(message: message);
  },
);
```

---

### 4. **PersonalityTestProvider** (NEW)
**File:** `lib/providers/personality_test_provider.dart`

**Fungsi:**
- Manage personality test questions
- Track user answers
- Calculate personality scores
- Determine mascot based on result

**Models:**
- `Question` - Single question dengan multiple answers
- `Answer` - Answer option dengan weights
- `TestResult` - Result dengan mascot, scores, description, traits

**Methods:**
- `loadQuestions()` - Load dari assets/data/personality_questions.json
- `answerQuestion(String answerId)` - Answer dan move to next
- `previousQuestion()` - Kembali ke question sebelumnya
- `goToQuestion(int index)` - Jump ke question tertentu
- `calculateResult()` - Hitung mascot berdasarkan scores
- `saveResult()` - Save ke backend (TODO)
- `resetTest()` - Reset untuk retake

**Mascot Mapping:**
- Logic → Komodo
- Courage → Harimau
- Spirituality → Garuda
- Creativity → Merak
- Empathy → Orangutan
- Social → Gajah
- Principle → Banteng

**Usage:**
```dart
// Load questions
await testProvider.loadQuestions();

// Answer question
testProvider.answerQuestion('A');

// Display progress
LinearProgressIndicator(value: testProvider.progress);

// Get result
if (testProvider.isTestComplete) {
  final result = testProvider.result;
  Text('Your mascot: ${result?.mascot}');
  Text(result?.description ?? '');
}
```

---

## 📝 Integration dengan Main.dart

Semua provider sudah ditambahkan ke `MultiProvider` di `main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => QrProvider()),
    ChangeNotifierProvider(create: (_) => character_matcher.PersonalityTestProvider()),
    ChangeNotifierProvider(create: (_) => HomeProvider()),
    ChangeNotifierProvider(create: (_) => ProfileProvider()),
    ChangeNotifierProvider(create: (_) => ChatbotProvider()),
  ],
  // ...
)
```

---

## 🔄 Next Steps (TODO)

### Fase 1: Integration
1. Update `HomeScreen` untuk menggunakan `HomeProvider`
2. Update `ProfileScreen` untuk menggunakan `ProfileProvider`
3. Update `ChatbotScreen` untuk menggunakan `ChatbotProvider`
4. Update `PersonalityTestScreen` untuk menggunakan `PersonalityTestProvider` (new)

### Fase 2: Backend Integration
1. Connect `HomeProvider` ke Supabase untuk sync XP/Level
2. Connect `ProfileProvider` ke Supabase untuk user data
3. Connect `ChatbotProvider` ke AI API (OpenAI/Gemini)
4. Connect `PersonalityTestProvider` untuk save results

### Fase 3: Features
1. Add offline caching
2. Add real-time sync
3. Add achievements/badges system
4. Add leaderboard

---

## ✅ Implementation Status

### Completed Screens
- ✅ **HomeScreen** - Uses HomeProvider
- ✅ **MainScreen** - Uses HomeProvider + ProfileProvider
- ✅ **ProfileScreen** - Uses HomeProvider + ProfileProvider
- ✅ **ChatbotScreen** - Uses ChatbotProvider
- ✅ **PersonalityTestScreen** - Uses character-matcher PersonalityTestProvider
- ✅ **MascotResultScreen** - Uses ProfileProvider to save mascot

### Pending Integration
- 🔄 Backend (Supabase) integration for all providers
- 🔄 AuthProvider integration for real user IDs
- 🔄 Sync profile data across app

---

## 🎯 Provider Benefits

✅ **Centralized State** - Semua state di satu tempat
✅ **Separation of Concerns** - Logic terpisah dari UI
✅ **Reusability** - Provider bisa dipakai di mana saja
✅ **Testability** - Mudah di-test
✅ **Performance** - Efficient rebuilds dengan Consumer
✅ **Scalability** - Mudah ditambah fitur baru

---

## 📚 Resources

- [Provider Package](https://pub.dev/packages/provider)
- [Flutter State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
- [Provider Architecture](https://codewithandrea.com/articles/flutter-state-management-setstate-riverpod/)
