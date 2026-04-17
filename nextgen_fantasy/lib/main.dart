import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  // Disponible globalmente como Supabase.instance.client.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // ProviderScope es el contenedor raíz de todos los providers de Riverpod.
  // Debe envolver toda la app para que cualquier widget pueda acceder
  // al estado global. Dev 2 creará los providers dentro de este scope
  // en lib/shared/providers/ y lib/features/*/domain/.
  runApp(
    const ProviderScope(
      child: NextGenFantasyApp(),
    ),
  );
}
