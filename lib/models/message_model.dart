// untuk chatbot
enum MessageSender { user, gemini }

class Message {
  final String text;
  final MessageSender sender;

  Message({required this.text, required this.sender});
}
