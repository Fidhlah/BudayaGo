import 'package:flutter/foundation.dart';

enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_error': isError,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.assistant,
      ),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isError: json['is_error'] as bool? ?? false,
    );
  }

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
    );
  }
}

class ChatbotProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  String _mascot = 'default';

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get mascot => _mascot;
  bool get hasMessages => _messages.isNotEmpty;

  /// Initialize chatbot with mascot
  void initialize(String mascot) {
    _mascot = mascot;
    _messages = [];
    _error = null;

    // Add welcome message based on mascot
    final welcomeMessage = _getWelcomeMessage(mascot);
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: welcomeMessage,
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
    debugPrint('✅ Chatbot initialized with mascot: $mascot');
  }

  String _getWelcomeMessage(String mascot) {
    final welcomeMessages = {
      'default':
          'Halo! Saya adalah pemandu budaya Anda. Ada yang bisa saya bantu?',
      'garuda':
          'Halo Penjelajah! Saya Garuda, siap membantu Anda menjelajahi budaya Indonesia!',
      'komodo':
          'Selamat datang! Saya Komodo, mari kita eksplorasi kekayaan budaya Nusantara!',
      'orangutan':
          'Hai! Saya Orangutan, teman setia Anda dalam petualangan budaya!',
      'merak':
          'Salam budaya! Saya Merak, siap berbagi cerita indah tentang Indonesia!',
    };

    return welcomeMessages[mascot.toLowerCase()] ?? welcomeMessages['default']!;
  }

  /// Send a message to the chatbot
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Set loading state
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Call AI API (OpenAI, Gemini, or custom backend)
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock response based on message content
      final response = _generateMockResponse(content);

      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: response,
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMessage);

      debugPrint('✅ Message sent and response received');
    } catch (e) {
      _error = 'Failed to send message: $e';

      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: 'Maaf, terjadi kesalahan. Silakan coba lagi.',
        timestamp: DateTime.now(),
        isError: true,
      );
      _messages.add(errorMessage);

      debugPrint('❌ ChatbotProvider.sendMessage error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateMockResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('batik')) {
      return 'Batik adalah warisan budaya Indonesia yang sangat kaya! Setiap daerah memiliki motif batik yang unik. Misalnya, Batik Parang dari Yogyakarta melambangkan kekuatan dan keteguhan. Apakah Anda ingin tahu lebih banyak tentang batik dari daerah tertentu?';
    } else if (message.contains('tari') || message.contains('tarian')) {
      return 'Indonesia memiliki beragam tarian tradisional yang indah! Seperti Tari Saman dari Aceh yang terkenal dengan gerakannya yang kompak, atau Tari Pendet dari Bali yang anggun. Tarian mana yang ingin Anda pelajari?';
    } else if (message.contains('makanan') || message.contains('kuliner')) {
      return 'Kuliner Indonesia sangat beragam dan lezat! Rendang dari Sumatera Barat bahkan pernah dinobatkan sebagai makanan terenak di dunia oleh CNN. Ada juga Gudeg dari Yogyakarta, Soto dari berbagai daerah, dan masih banyak lagi!';
    } else if (message.contains('museum')) {
      return 'Museum adalah tempat yang tepat untuk belajar budaya! Di Indonesia ada banyak museum menarik seperti Museum Nasional, Museum Fatahillah, dan museum-museum daerah. Jangan lupa scan QR code saat berkunjung untuk mendapat XP bonus!';
    } else if (message.contains('terima kasih') || message.contains('thanks')) {
      return 'Sama-sama! Senang bisa membantu Anda menjelajahi budaya Indonesia. Ada yang lain yang ingin ditanyakan?';
    } else {
      return 'Terima kasih atas pertanyaannya! Sebagai pemandu budaya, saya siap membantu Anda belajar tentang batik, tarian, makanan, rumah adat, alat musik, dan berbagai aspek budaya Indonesia lainnya. Apa yang ingin Anda ketahui?';
    }
  }

  /// Load chat history (from local storage or backend)
  Future<void> loadChatHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Load from SharedPreferences or Supabase
      await Future.delayed(const Duration(milliseconds: 300));

      // For now, start fresh
      debugPrint('✅ Chat history loaded');
    } catch (e) {
      _error = 'Failed to load chat history: $e';
      debugPrint('❌ ChatbotProvider.loadChatHistory error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save chat history (to local storage or backend)
  Future<void> saveChatHistory() async {
    try {
      // TODO: Save to SharedPreferences or Supabase
      debugPrint('✅ Chat history saved (${_messages.length} messages)');
    } catch (e) {
      debugPrint('❌ ChatbotProvider.saveChatHistory error: $e');
    }
  }

  /// Clear all messages
  void clearChat() {
    _messages = [];
    _error = null;

    // Add welcome message again
    final welcomeMessage = _getWelcomeMessage(_mascot);
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: welcomeMessage,
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
    debugPrint('🔄 Chat cleared');
  }

  /// Delete a specific message
  void deleteMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
    debugPrint('🗑️ Message deleted: $messageId');
  }

  @override
  void dispose() {
    saveChatHistory(); // Save before disposing
    super.dispose();
  }
}
