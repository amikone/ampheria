import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_config.dart';

class SupabaseManager extends ChangeNotifier {
  static const String _currentServerKey = 'current_supabase_server';
  static final SupabaseManager _instance = SupabaseManager._internal();

  factory SupabaseManager() => _instance;

  SupabaseManager._internal();

  SupabaseConfig? _currentConfig;
  SupabaseConfig? get currentConfig => _currentConfig;

  bool _initialized = false;
  bool get initialized => _initialized;

  final SupabaseConfig defaultServer = SupabaseConfig(
    name: "Amikone Officiel",
    description: "Serveur principal géré par l'équipe",
    url: "https://amikone-api.endide.com",
    publishableKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzY0NzE2NDAwLCJleHAiOjE5MjI0ODI4MDB9.feIlUK_yvMG3IsfIVWkdeo7f0NHHNqWOacuAhU4rBUU",
  );

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final serverJson = prefs.getString(_currentServerKey);

    if (serverJson != null) {
      try {
        _currentConfig = SupabaseConfig.fromJson(json.decode(serverJson));
      } catch (e) {
        _currentConfig = defaultServer;
      }
    } else {
      _currentConfig = defaultServer;
    }

    try {
      await _initSupabase(_currentConfig!);
      _initialized = true;
    } catch (e) {
      debugPrint("Erreur initialisation Supabase avec config persistance: $e");
      if (_currentConfig?.url != defaultServer.url) {
        _currentConfig = defaultServer;
        await _initSupabase(defaultServer);
        _initialized = true;
      } else {
        rethrow;
      }
    }
  }

  Future<void> _initSupabase(SupabaseConfig config) async {
    final sessionKey = 'sb-${config.name.replaceAll(' ', '-').toLowerCase()}-auth-token';

    try {
      await Supabase.instance.dispose();
    } catch (_) {}

    await Supabase.initialize(
      url: config.url,
      publishableKey: config.publishableKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SharedPreferencesLocalStorage(
          persistSessionKey: sessionKey,
        ),
      ),
    );
  }

  Future<void> changeServer(SupabaseConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentServerKey, json.encode(config.toJson()));
    
    _currentConfig = config;
    await _initSupabase(config);
    _initialized = true;
    notifyListeners();
  }
}
