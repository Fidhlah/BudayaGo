import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Import for debugPrint
import '../config/supabase_config.dart'; // Import for current user access

/// A service class to handle all communication with the customized
/// Gemini RAG API endpoint (your Cloudflare Worker).
class ChatService {
  static const String workerUrl = 'https://budayago.kiyahh.workers.dev/';

  // 1. Prepare the URI
  Future<String> sendMessage(
    String userMessage, {
    String character = 'timun mas', // TODO: ubah jadi dinamis
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

    // 2. Prepare the JSON body structure
    final bodyJson = jsonEncode(<String, String>{
      'message': userMessage,
      'character': character,
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
      if (response.statusCode == 200) {
        // Successful response from your Worker

        // Decode the JSON response body
        final jsonResponse = jsonDecode(response.body);

        // Ensure the key 'response' matches what the Worker sends back: { "response": "..." }
        final llmResponse = jsonResponse['response'] as String?;

        if (llmResponse != null) {
          return llmResponse;
        } else {
          // Handle case where 'response' field is missing or null
          return 'Server response was malformed. The chat service did not return the expected field.';
        }
      } else {
        // Handle non-200 status codes (e.g., 400 Bad Request, 500 Server Error)
        // Log the error body for debugging
        debugPrint('API Error ${response.statusCode}: ${response.body}');

        // Try to return a friendly error message
        try {
          final errorJson = jsonDecode(response.body);
          final errorMessage = errorJson['error'] ?? 'Unknown server error.';
          return 'Sorry, a server error occurred (Code: ${response.statusCode}). Details: $errorMessage';
        } catch (_) {
          return 'Sorry, a server error occurred (Code: ${response.statusCode}).';
        }
      }
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
}
