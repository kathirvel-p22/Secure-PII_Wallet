import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyBckGNbr7qInr-L9-bQlXxljvzR0IttlPE';
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
    
    _chat = _model.startChat(history: [
      Content.text('''You are SecureAI, an intelligent assistant integrated into the Secure Wallet app. 
Your role is to help users with:
- Security and encryption questions
- File management guidance
- Privacy best practices
- App feature explanations
- General assistance

Be helpful, concise, and security-focused. Never ask for or store sensitive user data.'''),
      Content.model([TextPart('Hello! I\'m SecureAI, your security-focused assistant. How can I help you today?')]),
    ]);
  }

  /// Send a message and get AI response
  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'I apologize, but I couldn\'t generate a response. Please try again.';
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Start a new chat session
  void resetChat() {
    _chat = _model.startChat(history: [
      Content.text('''You are SecureAI, an intelligent assistant integrated into the Secure Wallet app. 
Your role is to help users with:
- Security and encryption questions
- File management guidance
- Privacy best practices
- App feature explanations
- General assistance

Be helpful, concise, and security-focused. Never ask for or store sensitive user data.'''),
      Content.model([TextPart('Hello! I\'m SecureAI, your security-focused assistant. How can I help you today?')]),
    ]);
  }

  /// Get chat history
  List<Content> getChatHistory() {
    return _chat.history.toList();
  }
}
