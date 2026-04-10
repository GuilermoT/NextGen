import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextgen_fantasy/app/app.dart';
import 'package:nextgen_fantasy/core/config/supabase_config.dart';

Future<void> main() async {
  // Garantiza que los bindings de Flutter están inicializados
  // antes de ejecutar operaciones asíncronas.
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las variables de entorno desde el archivo .env local.
  await dotenv.load(fileName: '.env');

  // Inicializa el cliente de Supabase con las credenciales del .env.
  // Este cliente estará disponible globalmente como Supabase.instance.client
  // y será usado por todos los repositorios de datos (Fase 2.7 en adelante).
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const NextGenFantasyApp());
}
