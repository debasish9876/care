import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:translator/translator.dart'; // Translator package for translation

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool _isLoading = false;

  // Initialize the model
  final model = GenerativeModel(
    model: 'gemini-pro', // Use your chosen model
    apiKey: "AIzaSyDkmHakCRnJHQfr3dmkA3aS-8reYbCB0ec", // Replace with your actual API key
  );

  // Create a chat instance
  late final chat = model.startChat();

  // Initialize the translator
  final translator = GoogleTranslator();

  // User's selected language
  String selectedLanguage = 'en'; // Default is English

  void sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": message});
      _isLoading = true;
    });

    try {
      // Translate user input to English
      final translatedInput = await translator.translate(message, to: 'en');

      // Send translated message to Gemini
      final response = await chat.sendMessage(Content.text(translatedInput.text));
      final responseText = response.text ?? 'No response received';

      // Translate Gemini's response back to the user's selected language
      final translatedResponse = await translator.translate(responseText, to: selectedLanguage);

      setState(() {
        messages.add({"role": "assistant", "content": translatedResponse.text});
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        messages.add({
          "role": "assistant",
          "content": "Error: Unable to process your request. Please try again."
        });
        _isLoading = false;
      });
      debugPrint('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MediBot"),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.language, color: Colors.white),
              underline: const SizedBox(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                DropdownMenuItem(value: 'bn', child: Text('Bengali')),
                DropdownMenuItem(value: 'te', child: Text('Telugu')),
                DropdownMenuItem(value: 'ta', child: Text('Tamil')),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["role"] == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      message["content"]!,
                      style: TextStyle(
                        color: isUser ? Colors.black87 : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        sendMessage(value);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
