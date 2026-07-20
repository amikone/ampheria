// lib/services/GenderService.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class GenderService {
  static final _supabase = Supabase.instance.client;

  static List<String>? _cachedGenders;

  static Future<List<String>> fetchGenders() async {
    if (_cachedGenders != null) return _cachedGenders!;

    final response = await _supabase
        .from('genders')
        .select('name')
        .order('id');

    _cachedGenders = List<String>.from(
      response.map((e) => e['name'] as String),
    );

    return _cachedGenders!;
  }

  static void clearCache() => _cachedGenders = null;
}