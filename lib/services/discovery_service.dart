import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supabase_config.dart';

class DiscoveryService {
  static const String _defaultUrl = 'https://raw.githubusercontent.com/amikone/world/refs/heads/main/world.json';

  Future<List<SupabaseConfig>> fetchServers([String? url]) async {
    try {
      final response = await http.get(Uri.parse(url ?? _defaultUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SupabaseConfig.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load servers');
      }
    } catch (e) {
      print('Error fetching servers: $e');
      return [];
    }
  }
}
