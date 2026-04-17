// Configuración del cliente Supabase.
//
// Lee las credenciales exclusivamente desde el archivo .env local.
// Las credenciales reales NUNCA se escriben en este archivo.
//
// Uso:
//   En main.dart: Supabase.initialize(url: SupabaseConfig.url, ...)
//   En repositorios (Fase 2.7): Supabase.instance.client
//
// Los valores reales de url y anonKey se obtienen en:
//   supabase.com → tu proyecto → Settings → API

import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static String get url {
    final value = dotenv.env['SUPABASE_URL'] ?? '';
    assert(value.isNotEmpty, 'SUPABASE_URL no está definida en el archivo .env');
    return value;
  }

  static String get anonKey {
    final value = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    assert(value.isNotEmpty, 'SUPABASE_ANON_KEY no está definida en el archivo .env');
    return value;
  }
}
