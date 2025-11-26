import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Import for debugPrint
import '../config/supabase_config.dart'; // Import for current user access

/// A service class to handle all communication with the customized
/// Gemini RAG API endpoint (your Cloudflare Worker).
class ChatService {
  static const String workerUrl = 'https://budayago.kiyahh.workers.dev/';

  /// Get user's character name from Supabase
  static Future<String> _getUserCharacterName(String userId) async {
    try {
      debugPrint('🎭 Getting user character name for: $userId');

      // Get user's character_id
      final userData =
          await SupabaseConfig.client
              .from('users')
              .select('character_id')
              .eq('id', userId)
              .single();

      final characterId = userData['character_id'];
      if (characterId == null) {
        debugPrint('⚠️ User has no character assigned, using default');
        return 'timun mas'; // fallback default
      }

      // Get character name
      final characterData =
          await SupabaseConfig.client
              .from('characters')
              .select('name')
              .eq('id', characterId)
              .single();

      final characterName = characterData['name'] as String;
      debugPrint('✅ Found character: $characterName');
      return characterName;
    } catch (e) {
      debugPrint('❌ Error getting character name: $e');
      return 'timun mas'; // fallback default
    }
  }

  /// Save single message to Supabase
  static Future<void> saveMessage({
    required String userId,
    required String message,
    required String sender, // 'user' or 'bot'
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();

      await SupabaseConfig.client.from('chat_messages').insert({
        'user_id': userId,
        'message': message,
        'sender': sender,
        'session_id': userId,
        'timestamp': timestamp,
      });

      debugPrint(
        '✅ Message saved: $sender -> ${message.substring(0, math.min(50, message.length))}...',
      );
    } catch (e) {
      debugPrint('❌ Error saving message: $e');
    }
  }

  // 1. Prepare the URI
  Future<String> sendMessage(
    String userMessage, {
    String? character, // Optional, will be auto-detected from user's profile
    String? username, // Made optional, will be auto-detected from auth
  }) async {
    final uri = Uri.parse(workerUrl);

    // Get current user dynamically if username not provided
    final currentUser = SupabaseConfig.currentUser;
    final sessionId =
        username ?? currentUser?.id ?? currentUser?.email ?? 'anonymous_user';

    debugPrint('🔐 ChatService: Using sessionId: $sessionId');
    debugPrint('   User ID: ${currentUser?.id}');
    debugPrint('   User Email: ${currentUser?.email}');

    // Get character name dynamically if not provided
    final characterName =
        character ??
        (currentUser?.id != null
            ? await _getUserCharacterName(currentUser!.id)
            : 'timun mas');

    debugPrint('🎭 Using character: $characterName');

    // 2. Prepare the JSON body structure
    final bodyJson = jsonEncode(<String, String>{
      'message': userMessage,
      'character': characterName,
      'sessionId': sessionId,
    });

    try {
      // 3. Make the POST request
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: bodyJson,
      );

      // 4. Check for success status code
      String responseMessage;

      if (response.statusCode == 200) {
        // Successful response from your Worker
        final jsonResponse = jsonDecode(response.body);
        final llmResponse = jsonResponse['response'] as String?;

        if (llmResponse != null) {
          responseMessage = llmResponse;
        } else {
          // Handle case where 'response' field is missing or null
          responseMessage =
              'Server response was malformed. The chat service did not return the expected field.';
        }
      } else {
        // Handle non-200 status codes (e.g., 400 Bad Request, 500 Server Error)
        debugPrint('API Error ${response.statusCode}: ${response.body}');

        // Try to return a friendly error message
        try {
          final errorJson = jsonDecode(response.body);
          final errorMessage = errorJson['error'] ?? 'Unknown server error.';
          responseMessage =
              'Sorry, a server error occurred (Code: ${response.statusCode}). Details: $errorMessage';
        } catch (_) {
          responseMessage =
              'Sorry, a server error occurred (Code: ${response.statusCode}).';
        }
      }

      // Note: Messages will be saved individually when displayed in chat screen
      return responseMessage;
    } on http.ClientException catch (e) {
      // Handle HTTP-specific errors like connection timeout, host lookup failure, or CORS
      debugPrint('Network/Client Error: $e');
      return 'Network Error: Could not connect to the chat service. Please check your network connection.';
    } catch (e) {
      // Catch all other exceptions (e.g., Json decoding error if response is invalid)
      debugPrint('General Exception: $e');
      return 'An unexpected error occurred during processing.';
    }
  }

  /// Load chat messages from Supabase table
  static Future<List<Map<String, dynamic>>> loadChatHistory({
    required String userId,
    required String character,
  }) async {
    try {
      debugPrint('📚 Loading chat history from Supabase...');
      debugPrint('   User ID: $userId');
      debugPrint('   Character: $character');

      final data = await SupabaseConfig.client
          .from('chat_messages')
          .select('message, sender, timestamp, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      debugPrint('✅ Loaded ${data.length} chat messages');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('❌ Error loading chat history: $e');
      return [];
    }
  }

  /// Clear chat history for a specific user and character
  static Future<void> clearChatHistory({
    required String userId,
    required String character,
  }) async {
    try {
      debugPrint('🗑️ Clearing chat history...');
      debugPrint('   User ID: $userId');
      debugPrint('   Character: $character');

      await SupabaseConfig.client
          .from('chat_messages')
          .delete()
          .eq('user_id', userId);

      debugPrint('✅ Chat history cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing chat history: $e');
      rethrow;
    }
  }
}
