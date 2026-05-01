import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiTtsService {
  final String apiKey;
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  GeminiTtsService({required this.apiKey});
  
  /// Generate speech from text using Gemini 3.1 Flash TTS API
  Future<List<int>?> generateSpeech({
    required String text,
    required String voiceProfile,
    required List<String> audioTags,
    required String audioFormat,
  }) async {
    try {
      // Validate inputs
      if (text.trim().isEmpty) {
        print('Error: Text input cannot be empty');
        return null;
      }
      
      if (apiKey.isEmpty) {
        print('Error: API Key not configured');
        return null;
      }
      
      // Build request body
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': _buildPrompt(text, voiceProfile, audioTags),
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 8192,
        }
      };
      
      // Send POST request
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          print('Error: API request timeout');
          throw TimeoutException('Gemini API request timed out');
        },
      );
      
      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Extract audio content from response
        final audioContent = _extractAudioContent(responseData, audioFormat);
        return audioContent;
      } else if (response.statusCode == 429) {
        print('Error: Rate limit exceeded (429)');
        return null;
      } else if (response.statusCode == 400) {
        print('Error: Bad request (400) - ${response.body}');
        return null;
      } else if (response.statusCode == 401) {
        print('Error: Unauthorized (401) - Invalid API key');
        return null;
      } else {
        print('Error: API returned status ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating speech: $e');
      return null;
    }
  }
  
  /// Build prompt with voice profile and audio tags
  String _buildPrompt(String text, String voiceProfile, List<String> audioTags) {
    final tagsString = audioTags.isNotEmpty ? audioTags.join(', ') : 'neutral';
    
    return '''
Convert the following text to speech with these specifications:

TEXT: "$text"

VOICE PROFILE: $voiceProfile
AUDIO TAGS: $tagsString

Requirements:
- Use the specified voice profile for delivery style
- Apply the audio tags to the speech characteristics
- Ensure natural, professional output
- Output as high-quality audio suitable for professional use
''';
  }
  
  /// Extract audio content from Gemini API response
  List<int>? _extractAudioContent(Map<String, dynamic> responseData, String audioFormat) {
    try {
      // Navigate response structure: candidates[0].content.parts[0].text
      if (responseData.containsKey('candidates') && responseData['candidates'] is List) {
        final candidates = responseData['candidates'] as List;
        
        if (candidates.isNotEmpty && candidates[0] is Map) {
          final candidate = candidates[0] as Map<String, dynamic>;
          
          if (candidate.containsKey('content') && candidate['content'] is Map) {
            final content = candidate['content'] as Map<String, dynamic>;
            
            if (content.containsKey('parts') && content['parts'] is List) {
              final parts = content['parts'] as List;
              
              if (parts.isNotEmpty && parts[0] is Map) {
                final part = parts[0] as Map<String, dynamic>;
                
                // Extract base64 audio or binary data
                if (part.containsKey('inlineData') && part['inlineData'] is Map) {
                  final inlineData = part['inlineData'] as Map<String, dynamic>;
                  
                  if (inlineData.containsKey('data')) {
                    final base64Data = inlineData['data'] as String;
                    return base64Decode(base64Data);
                  }
                }
              }
            }
          }
        }
      }
      
      print('Warning: Could not extract audio content from response');
      return null;
    } catch (e) {
      print('Error extracting audio content: $e');
      return null;
    }
  }
  
  /// Validate API key format
  bool isValidApiKey(String key) {
    return key.isNotEmpty && key.length > 10;
  }
  
  /// Check API connectivity
  Future<bool> testApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey'),
      ).timeout(
        Duration(seconds: 10),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error testing API connection: $e');
      return false;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}
