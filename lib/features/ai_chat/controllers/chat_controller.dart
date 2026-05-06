import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  return ChatController();
});

class ChatController extends StateNotifier<List<ChatMessage>> {
  final GeminiService _geminiService = GeminiService();
  final Uuid _uuid = const Uuid();

  ChatController() : super([]) {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      text: 'Hello! I\'m SecureAI, your security-focused assistant. I can help you with:\n\n'
          '🔐 Security & encryption questions\n'
          '📁 File management guidance\n'
          '🛡️ Privacy best practices\n'
          '💡 App feature explanations\n\n'
          'How can I assist you today?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = [welcomeMessage];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMessage];

    // Add loading indicator
    final loadingMessage = ChatMessage(
      id: _uuid.v4(),
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    state = [...state, loadingMessage];

    try {
      // Get AI response
      final response = await _geminiService.sendMessage(text);

      // Remove loading indicator and add actual response
      state = state.where((msg) => !msg.isLoading).toList();
      
      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, aiMessage];
    } catch (e) {
      // Remove loading indicator and show error
      state = state.where((msg) => !msg.isLoading).toList();
      
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'Sorry, I encountered an error: ${e.toString()}\n\nPlease try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    }
  }

  void clearChat() {
    _geminiService.resetChat();
    state = [];
    _addWelcomeMessage();
  }

  void deleteMessage(String id) {
    state = state.where((msg) => msg.id != id).toList();
  }
}
