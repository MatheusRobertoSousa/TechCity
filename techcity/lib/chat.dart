import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addMessage('Athena', 'Olá! Sou a Athena, sua assistente virtual do TechCity. Como posso ajudá-lo hoje?');
  }

  void _addMessage(String sender, String message) {
    setState(() {
      _messages.add({
        'sender': sender,
        'message': message,
        'timestamp': DateTime.now(),
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String userMessage = _messageController.text.trim();
    _addMessage('Você', userMessage);
    _messageController.clear();

    Future.delayed(Duration(seconds: 1), () {
      String response = _generateAthenaResponse(userMessage);
      _addMessage('Athena', response);
    });
  }

  String _generateAthenaResponse(String message) {
    String lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('temperatura') || lowerMessage.contains('clima')) {
      return 'Posso ajudá-lo com informações sobre temperatura e clima! Verifique a seção de Sensores para dados em tempo real da sua região.';
    } else if (lowerMessage.contains('chamado') || lowerMessage.contains('problema')) {
      return 'Para relatar um problema, acesse a opção "Novo Chamado" no dashboard. Posso acompanhar o status dos seus chamados também.';
    } else if (lowerMessage.contains('mapa')) {
      return 'O mapa mostra a localização de sensores, câmeras e outros dispositivos inteligentes da cidade, além dos seus chamados.';
    } else if (lowerMessage.contains('ajuda') || lowerMessage.contains('help')) {
      return 'Posso ajudá-lo com:\n• Informações sobre sensores ambientais\n• Status de chamados\n• Navegação no app\n• Dados da Smart City';
    } else if (lowerMessage.contains('obrigado') || lowerMessage.contains('obrigada')) {
      return 'De nada! Estou sempre aqui para ajudar. 😊';
    } else {
      return 'Interessante! Posso ajudá-lo com informações sobre o TechCity, sensores ambientais, chamados ou navegação no aplicativo. O que você gostaria de saber?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, color: Color(0xFF3B7D3C)),
            ),
            SizedBox(width: 8),
            Text('Athena - IA Assistant'),
          ],
        ),
        backgroundColor: Color(0xFF3B7D3C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'Você';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser ? Color(0xFF3B7D3C) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'],
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${message['timestamp'].hour}:${message['timestamp'].minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -1),
                  blurRadius: 4,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  backgroundColor: Color(0xFF3B7D3C),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
