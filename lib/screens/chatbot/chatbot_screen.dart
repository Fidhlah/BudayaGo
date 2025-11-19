import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  final String mascot;

  const ChatbotScreen({Key? key, required this.mascot}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Pesan sambutan
    _messages.add({
      'sender': 'bot',
      'message':
          'Halo! Aku ${widget.mascot}, pemandu budayamu. Ada yang ingin kamu tanyakan tentang budaya Indonesia?',
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': _messageController.text});

      // Simulasi respons bot
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'message': _getBotResponse(_messageController.text),
          });
        });
      });
    });

    _messageController.clear();
  }

  String _getBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('batik')) {
      return 'Batik adalah warisan budaya Indonesia yang telah diakui UNESCO! Batik dibuat dengan teknik pewarnaan kain menggunakan malam (lilin). Ada batik tulis dan batik cap. Setiap motif batik punya makna tersendiri, lho!';
    } else if (lowerMessage.contains('tari') ||
        lowerMessage.contains('tarian')) {
      return 'Indonesia punya banyak tarian tradisional yang indah! Ada Tari Saman dari Aceh, Tari Pendet dari Bali, Tari Kecak, dan masih banyak lagi. Setiap tarian punya filosofi dan cerita di baliknya.';
    } else if (lowerMessage.contains('makanan') ||
        lowerMessage.contains('kuliner')) {
      return 'Kuliner Indonesia sangat beragam! Rendang dari Sumatra Barat bahkan pernah dinobatkan sebagai makanan terenak di dunia. Ada juga Gudeg, Soto, Gado-gado, dan ribuan makanan tradisional lainnya!';
    } else if (lowerMessage.contains('rumah adat')) {
      return 'Setiap daerah di Indonesia punya rumah adat dengan arsitektur unik! Contohnya Rumah Gadang dari Minangkabau, Tongkonan dari Toraja, dan Rumah Joglo dari Jawa. Arsitekturnya mencerminkan filosofi hidup masyarakat setempat.';
    } else {
      return 'Pertanyaan menarik! Budaya Indonesia sangat kaya dan beragam. Coba eksplorasi kategori-kategori di beranda untuk belajar lebih banyak, ya! 😊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, color: Colors.orange.shade600),
            ),
            const SizedBox(width: 12),
            Text('Chat dengan ${widget.mascot}'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isBot = message['sender'] == 'bot';

                return Align(
                  alignment:
                      isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isBot
                              ? Colors.orange.shade50
                              : Colors.orange.shade600,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isBot ? 0 : 16),
                        bottomRight: Radius.circular(isBot ? 16 : 0),
                      ),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: isBot ? Colors.black87 : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesanmu...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.orange.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.orange.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.orange.shade600),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.orange.shade600,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
