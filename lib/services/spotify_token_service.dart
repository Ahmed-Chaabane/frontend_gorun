import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SpotifyTokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    const String backendRefreshUrl = "http://localhost:3000/api/spotify/refresh";

    final response = await http.post(
      Uri.parse(backendRefreshUrl),
      body: {"refresh_token": refreshToken},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveTokens(data['access_token'], refreshToken);
      return data;
    } else {
      throw Exception("Échec du rafraîchissement du token : ${response.body}");
    }
  }
}