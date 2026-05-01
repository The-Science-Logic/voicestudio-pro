import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiResult {
  final Uint8List? audioBytes;
  final bool rateLimited;
  final bool dailyLimitReached;
  final String? error;

  const ApiResult({
    this.audioBytes,
    this.rateLimited = false,
    this.dailyLimitReached = false,
    this.error,
  });
}

class ApiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-2.5-flash-preview-tts';

  Future<ApiResult> generateSpeech({
    required String apiKey,
    required String text,
    required String voice,
    required String format,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': text}
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {
          'voiceConfig': {
            'prebuiltVoiceConfig': {'voiceName': voice}
          }
        }
      }
    });

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 429) {
        final rb = response.body.toLowerCase();
        if (rb.contains('daily') || rb.contains('quota')) {
          return const ApiResult(dailyLimitReached: true);
        }
        return const ApiResult(rateLimited: true);
      }

      if (response.statusCode != 200) {
        return ApiResult(
            error: 'HTTP ${response.statusCode}: ${response.body}');
      }

      final decoded =
          jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return const ApiResult(error: 'No candidates in response');
      }

      final content =
          candidates[0]['content'] as Map<String, dynamic>?;
      if (content == null) {
        return const ApiResult(error: 'No content in candidate');
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        return const ApiResult(error: 'No parts in response');
      }

      for (final part in parts) {
        if (part is Map<String, dynamic> &&
            part.containsKey('inlineData')) {
          final inlineData =
              part['inlineData'] as Map<String, dynamic>;
          final b64 = inlineData['data'] as String?;
          if (b64 != null) {
            return ApiResult(audioBytes: base64Decode(b64));
          }
        }
      }

      return const ApiResult(
          error: 'No audio data found in response');
    } catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<bool> testApiKey(String apiKey) async {
    final result = await generateSpeech(
      apiKey: apiKey,
      text: 'Test.',
      voice: 'Puck',
      format: 'mp3',
    );
    return result.audioBytes != null;
  }
}
