import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Expone el SupabaseClient singleton como provider Riverpod.
/// Supabase.initialize() ya fue llamado en main.dart antes de runApp(),
/// por lo que esta lectura es siempre segura.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
