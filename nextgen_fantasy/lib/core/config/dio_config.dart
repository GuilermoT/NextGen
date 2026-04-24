import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class DioConfig {
  DioConfig._();

  static Dio createClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${SupabaseConfig.url}/rest/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(_AuthInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}

/// Inyecta las cabeceras de autenticación Supabase en cada petición saliente.
/// - apikey: siempre presente (requerido por PostgREST para todas las llamadas)
/// - Authorization: solo cuando hay sesión activa (peticiones autenticadas)
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['apikey'] = SupabaseConfig.anonKey;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    handler.next(options);
  }
}
