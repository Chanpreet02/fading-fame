import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  SupabaseClient get client => Supabase.instance.client;
}

final supabaseClientService = SupabaseClientService();
