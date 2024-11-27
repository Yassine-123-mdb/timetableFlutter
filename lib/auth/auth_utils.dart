import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Check if the user is authenticated
Future<bool> isAuthenticated() async {
  final token = await storage.read(key: 'jwt');
  return token != null; // Authenticated if token exists
}

// Save the JWT token
Future<void> saveToken(String token) async {
  await storage.write(key: 'jwt', value: token);
}

// Clear the JWT token on logout
Future<void> clearToken() async {
  await storage.delete(key: 'jwt');
}
