import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../models/holerite.dart';

class AuthService {
  final _client = ApiClient();
  final _storage = const FlutterSecureStorage();
  static const _keyToken = 'auth_token', _keyUser = 'user_info';

  Future<UserInfo> loginComCredenciais({required String login, required String senha}) async {
    try {
      final r = await _client.post(ApiConfig.login, data: {'login': login, 'senha': senha});
      final token = r.data['token'] ?? r.data['access_token'] ?? r.data['data']?['token'];
      if (token == null) throw ApiException('Token não encontrado');
      await _storage.write(key: _keyToken, value: token.toString());
      final u = UserInfo.fromJson(r.data['usuario'] ?? r.data['user'] ?? r.data['data'] ?? r.data);
      await _storage.write(key: _keyUser, value: jsonEncode(u.toMap()));
      return u;
    } on ApiException { rethrow; } catch (e) { throw ApiException('Falha no login: $e'); }
  }

  Future<UserInfo> loginComToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
    try {
      final r = await _client.get(ApiConfig.perfil);
      final u = UserInfo.fromJson(r.data['data'] ?? r.data);
      await _storage.write(key: _keyUser, value: jsonEncode(u.toMap()));
      return u;
    } catch (_) {
      final u = UserInfo(nome: 'Usuário', matricula: '', cargo: '', orgao: 'Questor Público');
      await _storage.write(key: _keyUser, value: jsonEncode(u.toMap()));
      return u;
    }
  }

  Future<bool> isLoggedIn() async { final t = await _storage.read(key: _keyToken); return t != null && t.isNotEmpty; }
  Future<String?> getToken() => _storage.read(key: _keyToken);
  Future<UserInfo?> getUserInfo() async { final j = await _storage.read(key: _keyUser); if (j == null) return null; try { return UserInfo.fromJson(jsonDecode(j)); } catch (_) { return null; } }
  Future<void> logout() => _storage.deleteAll();
}
