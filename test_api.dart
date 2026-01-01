import 'package:namer_app/services/moonshot_service.dart';

void main() async {
  final apiKey = 'sk-pALkes2xizTUZ9q9gFcEDaqXjpm2z4yfjjUsoD1Fv0dK7aiV';
  final service = MoonshotService(apiKey: apiKey);

  print('Testing Moonshot API with key: $apiKey');

  try {
    final response = await service.simpleChat('Hello, say hi!');
    print('Response: $response');
  } catch (e) {
    print('Error: $e');
  }
}
