import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    // 1. Add user message and update UI
    setState(() {
      _messages.insert(0, Message(text: text, sender: MessageSender.user));
      _isLoading = true;
    });
    _controller.clear();
    // Scroll to the newest message
    _scrollToBottom();

    // 2. Call the custom RAG API
    try {
      final response = await _chatService.sendMessage(text);

      // 3. Add Gemini response and update UI
      setState(() {
        _messages.insert(
          0,
          Message(text: response, sender: MessageSender.gemini),
        );
      });
    } catch (e) {
      // Handle errors caught in the service
      setState(() {
        _messages.insert(
          0,
          Message(text: 'System Error: $e', sender: MessageSender.gemini),
        );
      });
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isUser ? Colors.blue.shade600 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Text(
            message.text,
            style: TextStyle(color: isUser ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).profile;
    final mascotName = profile?.mascot ?? 'Maskot';

    return Scaffold(
      backgroundColor: AppColors.orange50,
      appBar: CustomGradientAppBar(title: 'Chat dengan $mascotName'),
      body: Column(
        children: <Widget>[
          // Message List (Reversed to show newest at the bottom)
          Expanded(
            child: ListView.builder(
              reverse: true, // New messages appear at the bottom
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading) const LinearProgressIndicator(),

          // Input Field
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask about your complex JSON data...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      onSubmitted: (text) => _sendMessage(),
                      enabled: !_isLoading, // Disable input while loading
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _isLoading ? Colors.grey : Colors.blue,
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
