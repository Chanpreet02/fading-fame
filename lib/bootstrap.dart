import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';

Future<void> initSupabase() async {
  if (AppConfig.supabaseUrl.isEmpty ||
      AppConfig.supabaseAnonKey.isEmpty) {
    throw Exception(
      'SUPABASE_URL or SUPABASE_ANON_KEY missing. '
          'Did you forget --dart-define?',
    );
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
}
