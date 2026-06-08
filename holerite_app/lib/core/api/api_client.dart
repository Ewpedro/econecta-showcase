import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ============================================================
// CONFIGURAÇÃO DA API — AJUSTE AQUI APÓS DESCOBRIR OS ENDPOINTS
// Use o DevTools do Chrome (aba Network) para capturar as
// requisições feitas pelo site fitcard.app.questorpublico.com.br
// ============================================================
class ApiConfig {
  static const String baseUrl = 'https://fitcard.app.questorpublico.com.br';

  // Endpoints (ajuste conforme o que você ver no DevTools)
  static const String login = '/api/auth/login';
  static const String holerites = '/api/holerites';
  static const String holeriteDetalhe = '/api/holerites/{id}';
  static const String holeritePdf = '/api/holerites/{id}/pdf';
  static const String perfil = '/api/usuario/perfil';

  // Header do token (ajuste conforme o que o site usa)
  static const String tokenHeader = 'Authorization';
  static const String tokenPrefix = 'Bearer ';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(_storage));
    _dio.interceptors.add(_LogInterceptor());
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response<ResponseBody>> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.get(
      path,
      options: Options(responseType: ResponseType.stream),
      onReceiveProgress: onReceiveProgress,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      options.headers[ApiConfig.tokenHeader] =
          '${ApiConfig.tokenPrefix}$token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.delete(key: 'auth_token');
    }
    handler.next(err);
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API ERROR] ${err.response?.statusCode} ${err.message}');
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
