import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// CONFIGURE OS ENDPOINTS AQUI após inspecionar o site com Chrome DevTools (F12 > Network)
class ApiConfig {
  static const String baseUrl = 'https://fitcard.app.questorpublico.com.br';
  static const String login = '/api/auth/login';
  static const String holerites = '/api/holerites';
  static const String holeritePdf = '/api/holerites/{id}/pdf';
  static const String perfil = '/api/usuario/perfil';
  static const String tokenHeader = 'Authorization';
  static const String tokenPrefix = 'Bearer ';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient._internal() {
    _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl, connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 60), headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}));
    _dio.interceptors.add(_AuthInterceptor(_storage));
  }

  Dio get dio => _dio;
  Future<Response> get(String path, {Map<String, dynamic>? params}) => _dio.get(path, queryParameters: params);
  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) options.headers[ApiConfig.tokenHeader] = '${ApiConfig.tokenPrefix}$token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) await _storage.delete(key: 'auth_token');
    handler.next(err);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}
