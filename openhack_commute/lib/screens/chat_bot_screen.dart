import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// O clasă simplă pentru a ține mesajele
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Adaugă mesajul de întâmpinare al bot-ului
    setState(() {
      _messages.add(ChatMessage(
          text: "Salut! Sunt asistentul tău virtual Commute. Cu ce te pot ajuta?",
          isUser: false));
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  // Funcția care trimite mesajul
  Future<void> _sendMessage() async {
    final String text = _chatController.text.trim();
    if (text.isEmpty) return;

    // Adaugă mesajul utilizatorului în listă
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    _chatController.clear();
    FocusManager.instance.primaryFocus?.unfocus();

    // --- AICI ESTE APELUL SECURIZAT CĂTRE BACKEND ---
    // Numele funcției tale Firebase (vezi Pasul 3)
    const String cloudFunctionUrl = "https://getchatreply-twkx4wj5za-uc.a.run.app";

    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': text}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String botReply = data['reply'];
        
        // Adaugă răspunsul bot-ului în listă
        setState(() {
          _messages.add(ChatMessage(text: botReply, isUser: false));
        });
      } else {
        // Gestionează eroarea de la backend
        _addErrorMessage();
      }
    } catch (e) {
      // Gestionează eroarea de rețea
      print("Eroare la apelul funcției cloud: $e");
      _addErrorMessage();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addErrorMessage() {
    setState(() {
      _messages.add(ChatMessage(
          text: "Oops! A apărut o eroare. Te rog încearcă din nou mai târziu.",
          isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Suport"),
      ),
      body: Column(
        children: [
          // Zona de mesaje
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Mesajele noi apar jos
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Afișăm lista invers pentru a avea bula de scriere mereu jos
                final message = _messages.reversed.toList()[index];
                return _buildChatBubble(message);
              },
            ),
          ),

          // Indicatorul "Bot-ul scrie..."
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 10),
                  Text("Asistentul scrie..."),
                ],
              ),
            ),

          // Zona de input
          _buildTextInput(),
        ],
      ),
    );
  }

  // Widget pentru bula de chat
  Widget _buildChatBubble(ChatMessage message) {
    final bool isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (stânga pentru bot)
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.support_agent, color: Colors.white),
            ),
          if (!isUser) const SizedBox(width: 8),

          // Bula cu text
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Colors.teal[400] : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(color: isUser ? Colors.white : Colors.black87),
              ),
            ),
          ),

          // Avatar (dreapta pentru user)
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  // Widget pentru câmpul de text
  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: "Scrie un mesaj...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (text) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          // Butonul de trimitere
          IconButton(
            icon: const Icon(Icons.send, color: Colors.teal),
            onPressed: _isLoading ? null : _sendMessage, // Dezactivat în timpul încărcării
          ),
        ],
      ),
    );
  }
}