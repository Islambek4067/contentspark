import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiService {
  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  static const _apiKey = 'AIzaSyDaei4dpc_cw_z2AJoePYFMPoSPoEQdcZ8';
  static const _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  static const systemPrompt = '''
You are ContentSpark AI - a specialized script writing assistant
built into the ContentSpark app.

Your ONLY purpose is to help users create compelling video scripts
for YouTube, Instagram Reels, and TikTok.

You help with:
- Writing full video scripts (hook, body, CTA)
- Suggesting video ideas based on niche/topic
- Improving existing scripts
- Adapting scripts for different platforms
- Generating hooks that grab attention in first 3 seconds

You do NOT help with:
- Unrelated topics (coding, math, general questions)
- If asked off-topic, say: 'I am ContentSpark AI - I can only
  help you create amazing video scripts! What topic do you
  want to cover today?'

Always respond in the SAME language the user writes in.
Always be creative, energetic, and encouraging.

IMPORTANT: Always return valid JSON only, in this EXACT format:
{
  "hook": "Your attention-grabbing opening (0-3 seconds)",
  "body": "Main content with key points",
  "cta": "Clear call to action at the end",
  "fullScript": "Complete script combining all three parts",
  "hashtags": "3-5 relevant hashtags separated by spaces (e.g., #topic #video)"
}
''';

  final http.Client _client;

  Future<Map<String, String>> generateScript({
    required String topic,
    required String platform,
  }) async {
    final response = await _client.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "systemInstruction": {
          "parts": [
            {
              "text": systemPrompt
            }
          ]
        },
        "contents": [
          {
            "parts": [
              {
                "text": "Platform: $platform. Topic: $topic"
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
          "responseMimeType": "application/json"
        }
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gemini API error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    if (content == null) {
      throw Exception('Gemini response did not include content.');
    }

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini response did not include parts.');
    }

    final text = parts.first['text'] as String?;
    if (text == null || text.isEmpty) {
      throw Exception('Gemini response did not include script text.');
    }

    final decoded = _decodeScriptJson(_extractJson(text));
    return {
      'hook': decoded['hook']?.toString() ?? '',
      'body': decoded['body']?.toString() ?? '',
      'cta': decoded['cta']?.toString() ?? '',
      'fullScript': decoded['fullScript']?.toString() ?? '',
      'hashtags': decoded['hashtags']?.toString() ?? '',
    };
  }

  String _extractJson(String text) {
    final cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```JSON', '')
        .replaceAll('```', '')
        .trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception('Gemini response was not valid JSON.');
    }
    return cleaned.substring(start, end + 1);
  }

  Map<String, dynamic> _decodeScriptJson(String jsonText) {
    try {
      return jsonDecode(jsonText) as Map<String, dynamic>;
    } on FormatException {
      final fields = <String, dynamic>{};
      for (final key in ['hook', 'body', 'cta', 'fullScript', 'hashtags']) {
        final pattern = RegExp(
          '''['"]$key['"]\\s*:\\s*(['"])([\\s\\S]*?)\\1\\s*(,|})''',
          multiLine: true,
        );
        final match = pattern.firstMatch(jsonText);
        if (match != null) {
          fields[key] = match.group(2) ?? '';
        }
      }
      if (fields.length >= 4) {
        return fields;
      }
      rethrow;
    }
  }
}
