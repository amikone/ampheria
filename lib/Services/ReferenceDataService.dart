// lib/services/reference_data_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class ReferenceDataService {
  static final _supabase = Supabase.instance.client;

  static List<String>? _cachedGenders;
  static List<String>? _cachedOrientations;

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

  static Future<List<String>> fetchOrientations() async {
    if (_cachedOrientations != null) return _cachedOrientations!;
    final response = await _supabase
        .from('orientations')
        .select('name')
        .order('id');
    _cachedOrientations = List<String>.from(
      response.map((e) => e['name'] as String),
    );
    return _cachedOrientations!;
  }

  // Suggestion automatique de interested_in selon l'orientation
  // Tu peux personnaliser ce mapping comme tu veux
  static List<String> suggestInterestedIn({
    required String orientation,
    required String myGender,
    required List<String> allGenders,
  }) {
    switch (orientation) {
      case 'Hétérosexuel(le)':
      // Suggère le genre "opposé" basique
        if (myGender == 'Homme') return ['Femme'];
        if (myGender == 'Femme') return ['Homme'];
        return [];

      case 'Homosexuel(le)':
      // Suggère le même genre
        return [myGender];

      case 'Bisexuel(le)':
        return ['Homme', 'Femme'];

      case 'Pansexuel(le)':
      case 'Queer':
      // Tous les genres
        return List<String>.from(allGenders);

      case 'Asexuel(le)':
      case 'En questionnement':
      // Pas de suggestion, laisse l'utilisateur choisir
        return [];

      default:
        return [];
    }
  }

  static void clearCache() {
    _cachedGenders = null;
    _cachedOrientations = null;
  }
}