// Cliente HTTP de NextGen Fantasy basado en Dio.
//
// Estado actual: stub vacío pendiente de implementación.
//
// Pendiente en Fase 2.7 (Dev 2 — feature/game-engine-flutter):
// Implementar DioConfig como clase con un método estático createClient()
// que devuelva una instancia de Dio configurada con:
//
// 1. BaseOptions:
//    - baseUrl: la URL base de la API REST de Supabase
//    - connectTimeout y receiveTimeout razonables (ej. 10 segundos)
//
// 2. AuthInterceptor:
//    Interceptor que en cada petición saliente:
//    - Lee el token JWT activo desde Supabase.instance.client.auth.currentSession
//    - Lo inyecta en la cabecera: Authorization: Bearer <token>
//    - Inyecta también la apikey de Supabase en la cabecera apikey
//    Esto evita que cada repositorio gestione la autenticación manualmente.
//
// 3. LoggingInterceptor (solo en modo debug):
//    Registra en consola el método, URL, cabeceras y body de cada petición
//    y respuesta para facilitar el diagnóstico durante el desarrollo.
//
// Uso previsto (una vez implementado):
//   final dio = DioConfig.createClient();
//   final response = await dio.get('/rest/v1/teams');

import 'package:dio/dio.dart';

class DioConfig {
  DioConfig._();

  // Implementación pendiente en Fase 2.7
  // ignore: unused_element
  static Dio _createClient() {
    return Dio();
  }
}
