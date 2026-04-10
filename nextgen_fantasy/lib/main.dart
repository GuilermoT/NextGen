import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nextgen_fantasy/app/app.dart';

Future<void> main() async {
  // Garantiza que los bindings de Flutter están inicializados
  // antes de ejecutar operaciones asíncronas.
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las variables de entorno desde el archivo .env local.
  // Este archivo no existe en el repositorio — cada desarrollador
  // tiene el suyo con los valores reales de Supabase.
  // En la Fase 0.C estos valores se usarán para inicializar Supabase.
  await dotenv.load(fileName: '.env');

  runApp(const NextGenFantasyApp());
}
