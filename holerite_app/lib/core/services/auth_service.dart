import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../models/holerite.dart';

class AuthService {
  final _client = ApiClient();
  final _storage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyUser = 'user_info';

  // Login com usuário e senha
  Future<UserInfo> loginComCredenciais({
    required String login,
    required String senha,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.login,
        data: {'login': login, 'senha': senha},
      );

      final token = response.data['token'] ??
          response.data['access_token'] ??
          response.data['data']?['token'];

      if (token == null) throw ApiException('Token não encontrado na resposta');

      await _storage.write(key: _keyToken, value: token.toString());

      final userInfo = _extractUserInfo(response.data);
      await _storage.write(key: _keyUser, value: jsonEncode(userInfo.toMap()));
      return userInfo;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha no login: ${e.toString()}');
    }
  }

  // Login direto com token (se o usuário já tiver o token)
  Future<UserInfo> loginComToken(String token) async {
    await _storage.write(key: _keyToken, value: token);

    try {
      final response = await _client.get(ApiConfig.perfil);
      final userInfo = UserInfo.fromJson(response.data['data'] ?? response.data);
      await _storage.write(key: _keyUser, value: jsonEncode(userInfo.toMap()));
      return userInfo;
    } catch (e) {
      // Se não conseguir buscar o perfil, usa dados genéricos
      final userInfo = UserInfo(
        nome: 'Usuário',
        matricula: '',
        cargo: '',
        orgao: 'Questor Público',
      );
      await _storage.write(key: _keyUser, value: jsonEncode(userInfo.toMap()));
      return userInfo;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyToken);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);

  Future<UserInfo?> getUserInfo() async {
    final userJson = await _storage.read(key: _keyUser);
    if (userJson == null) return null;
    try {
      return UserInfo.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  UserInfo _extractUserInfo(Map<String, dynamic> data) {
    final userData = data['usuario'] ?? data['user'] ?? data['data'] ?? data;
    return UserInfo.fromJson(userData);
  }
}
