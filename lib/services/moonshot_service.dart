import 'dart:convert';
import 'package:http/http.dart' as http;

class MoonshotService {
  final String apiKey;
  final String baseUrl;

  MoonshotService({
    required this.apiKey,
    this.baseUrl = 'https://api.moonshot.cn/v1',
  });

  /// Send a chat completion request to the Moonshot API.
  /// 
  /// [messages] is a list of maps, e.g.,
  /// [
  ///   {"role": "system", "content": "You are a helpful assistant."},
  ///   {"role": "user", "content": "Hello!"}
  /// ]
  /// 
  /// [model] defaults to 'moonshot-v1-8k'.
  Future<String> chat({
    required List<Map<String, String>> messages,
    String model = 'kimi-k2-turbo-preview',
    double temperature = 0.3,
  }) async {
    final url = Uri.parse('$baseUrl/chat/completions');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response to extract the content
        // ...
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['choices'] != null && 
            data['choices'] is List && 
            data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'].toString();
        } else {
          throw Exception('Empty choices in response');
        }
      } else {
        // Try to parse error message from response body
        String errorMessage = 'Failed to request Moonshot API: ${response.statusCode}';
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          if (errorData['error'] != null && errorData['error']['message'] != null) {
            errorMessage += ' - ${errorData['error']['message']}';
          } else {
            errorMessage += ' - ${response.body}';
          }
        } catch (_) {
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error calling Moonshot API: $e');
    }
  }

  /// Helper method for simple one-off prompts
  Future<String> simpleChat(String prompt) async {
    return chat(messages: [
      {'role': 'user', 'content': prompt}
    ]);
  }
}
