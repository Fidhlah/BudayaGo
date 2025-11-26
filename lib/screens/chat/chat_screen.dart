import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../config/supabase_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isLoadingHistory = true;

  // Queue for delayed messages
  List<String> _messageQueue = [];
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  /// Load chat history from database
  Future<void> _loadChatHistory() async {
    final currentUser = SupabaseConfig.currentUser;
    if (currentUser == null) {
      setState(() => _isLoadingHistory = false);
      return;
    }

    try {
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final character = profileProvider.character;

      if (character == null) {
        setState(() => _isLoadingHistory = false);
        return;
      }

      final chatHistory = await ChatService.loadChatHistory(
        userId: currentUser.id,
        character: character.name,
      );

      // Convert database records to Message objects
      final List<Message> loadedMessages = [];
      for (final record in chatHistory) {
        final sender =
            record['sender'] == 'user'
                ? MessageSender.user
                : MessageSender
                    .gemini; // handles 'bot', 'model', or any non-'user' value

        loadedMessages.add(Message(text: record['message'], sender: sender));
      }

      // Reverse to show newest first (UI shows reversed list)
      setState(() {
        _messages.clear();
        _messages.addAll(loadedMessages.reversed);
        _isLoadingHistory = false;
      });

      debugPrint('✅ Loaded ${loadedMessages.length} messages from history');
    } catch (e) {
      debugPrint('❌ Error loading chat history: $e');
      setState(() => _isLoadingHistory = false);
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Clear message queue and cancel timer
  void _clearMessageQueue() {
    _messageTimer?.cancel();
    _messageQueue.clear();
  }

  /// Send messages from queue with delays and typing indicators
  void _startDelayedMessagesWithTyping(List<String> messageParts) {
    _clearMessageQueue(); // Clear any existing queue
    _messageQueue = List.from(messageParts);
    _sendNextQueuedMessageWithTyping();
  }

  /// Send next message from queue with typing indicator
  void _sendNextQueuedMessageWithTyping() async {
    if (_messageQueue.isEmpty) return;

    final currentUser = SupabaseConfig.currentUser;
    final nextMessage = _messageQueue.removeAt(0);
    // Check if this is the last message
    final isFirstMessage = _messageQueue.isEmpty;

    // Add typing indicator (except for very first message - it already has one)
    if (!isFirstMessage) {
      setState(() {
        _messages.insert(0, Message(text: '...', sender: MessageSender.gemini));
      });
      _scrollToBottom();

      // Wait for typing delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Remove typing indicator if still there (user might have interrupted)
      if (_messages.isNotEmpty &&
          _messages.first.text == '...' &&
          _messages.first.sender == MessageSender.gemini) {
        setState(() {
          _messages.removeAt(0);
        });
      }
    }

    // Add actual message to UI
    setState(() {
      _messages.insert(
        0,
        Message(text: nextMessage, sender: MessageSender.gemini),
      );
    });
    _scrollToBottom();

    // Save message to database
    if (currentUser?.id != null) {
      await ChatService.saveMessage(
        userId: currentUser!.id,
        message: nextMessage,
        sender: 'bot',
      );
    }

    // Schedule next message if queue not empty
    if (_messageQueue.isNotEmpty) {
      _messageTimer = Timer(const Duration(seconds: 10), () {
        _sendNextQueuedMessageWithTyping();
      });
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Clear any ongoing delayed messages
    _clearMessageQueue();

    final currentUser = SupabaseConfig.currentUser;

    // 1. Add and save user message
    setState(() {
      _messages.insert(0, Message(text: text, sender: MessageSender.user));
      _messages.insert(
        0,
        Message(text: '...', sender: MessageSender.gemini),
      ); // Typing indicator
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Save user message to database
    if (currentUser?.id != null) {
      await ChatService.saveMessage(
        userId: currentUser!.id,
        message: text,
        sender: 'user',
      );
    }

    // 2. Call the custom RAG API
    try {
      final response = await _chatService.sendMessage(text);

      // 3. Remove typing indicator
      setState(() {
        _messages.removeAt(0); // Remove typing indicator
      });

      // 4. Split response and send with delays and typing indicators
      final messageParts =
          response
              .split('\n\n')
              .where((part) => part.trim().isNotEmpty)
              .map((part) => part.trim())
              .toList();

      if (messageParts.isNotEmpty) {
        _startDelayedMessagesWithTyping(messageParts);
      }
    } catch (e) {
      // Handle errors - save error message
      final errorMsg = 'System Error: $e';
      setState(() {
        _messages.removeAt(0); // Remove typing indicator
        _messages.insert(
          0,
          Message(text: errorMsg, sender: MessageSender.gemini),
        );
      });

      // Save error message to database
      if (currentUser?.id != null) {
        await ChatService.saveMessage(
          userId: currentUser!.id,
          message: errorMsg,
          sender: 'bot',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Scroll the list to the bottom (index 0, since it's reversed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- Widget Builders ---

  Widget _buildMessage(Message message) {
    // Determine color and alignment based on sender
    final isUser = message.sender == MessageSender.user;
    final isTyping = !isUser && message.text == '...';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient:
                isUser
                    ? LinearGradient(colors: AppColors.orangePinkGradient)
                    : null,
            color: isUser ? null : AppColors.grey100,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child:
              isTyping
                  ? _buildTypingIndicator()
                  : _buildFormattedText(
                    message.text,
                    isUser ? Colors.white : Colors.black87,
                  ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 60,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              // Create a wave effect by delaying each dot
              final delay = index * 0.3;
              final animationValue = (value - delay).clamp(0.0, 1.0);
              final opacity = (math.sin(animationValue * math.pi * 2) + 1) / 2;

              return AnimatedOpacity(
                opacity: opacity * 0.6 + 0.4, // Min opacity 0.4, max 1.0
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildFormattedText(String text, Color textColor) {
    final List<TextSpan> spans = [];
    final RegExp pattern = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
    int lastEnd = 0;

    for (final Match match in pattern.allMatches(text)) {
      // Add normal text before match
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: TextStyle(color: textColor),
          ),
        );
      }

      // Add formatted text
      if (match.group(1) != null) {
        // **bold** text
        spans.add(
          TextSpan(
            text: match.group(1)!,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(2) != null) {
        // *italic* text
        spans.add(
          TextSpan(
            text: match.group(2)!,
            style: TextStyle(color: textColor, fontStyle: FontStyle.italic),
          ),
        );
      }

      lastEnd = match.end;
    }

    // Add remaining normal text
    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: TextStyle(color: textColor),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final character = Provider.of<ProfileProvider>(context).character;
    final mascotName = character?.name ?? '???';

    return Scaffold(
      backgroundColor: AppColors.orange50,
      appBar: CustomGradientAppBar(title: 'Chat dengan $mascotName'),
      body: Column(
        children: <Widget>[
          // Message List (Reversed to show newest at the bottom)
          Expanded(
            child:
                _isLoadingHistory
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Memuat riwayat chat...'),
                        ],
                      ),
                    )
                    : ListView.builder(
                      reverse: true, // New messages appear at the bottom
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessage(_messages[index]);
                      },
                    ),
          ),

          // Loading indicator removed - using typing indicator in messages instead

          // Input Field
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText:
                            'Tanya $mascotName tentang budaya Indonesia...',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                      ),
                      onSubmitted: (text) => _sendMessage(),
                      enabled: !_isLoading, // Disable input while loading
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _isLoading ? Colors.grey : AppColors.orange700,
                    ),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
