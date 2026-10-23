import 'dart:async';

import 'package:ampheria/presentation/login_view.dart';
import 'package:ampheria/presentation/page/chat/chat_page.dart';
import 'package:ampheria/presentation/page/health/health_page.dart';
import 'package:ampheria/presentation/page/like/like_page.dart';
import 'package:ampheria/presentation/page/people/people_page.dart';
import 'package:ampheria/presentation/page/profile/profile_screen.dart';
import 'package:ampheria/presentation/page/server_picker_page.dart';
import 'package:ampheria/presentation/widgets/bottom_nav_bar.dart';
import 'package:ampheria/l10n/app_localizations.dart';
import 'package:ampheria/services/supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseManager().initialize();
  } catch (e, stackTrace) {
    debugPrint("Erreur lors de l'initialisation de Supabase: $e\n$stackTrace");
  }

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> updateUserLocation() async {
  try {
    if (!SupabaseManager().initialized) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) return;

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    );

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId != null) {
      await supabase.from('profiles').update({
        'location': 'POINT(${position.longitude} ${position.latitude})'
      }).eq('id', userId);
    }
  } catch (e) {
    debugPrint("Erreur lors de la récupération/mise à jour de la position: $e");
  }
}

Future<void> updateUserActivity() async {
  try {
    if (!SupabaseManager().initialized) return;
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    await supabase.from('profiles').update({
      'last_active_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  } catch (e) {
    debugPrint("Erreur lors de la mise à jour de last_active_at: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amikone',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...material_ui.GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          surface: Color(0xFF1E1E2C),
          onSurface: Colors.white,
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2C),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardColor: const Color(0xFF1E1E2C),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFBB86FC),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
      home: const AuthStateHandler(),
      routes: {
        '/home': (context) => const MainPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  Session? _session;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isLoading = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initAuth();
    SupabaseManager().addListener(_onServerChanged);
  }

  Future<void> _initAuth() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _initError = null;
    });

    try {
      if (!SupabaseManager().initialized) {
        await SupabaseManager().initialize();
      }

      if (SupabaseManager().initialized) {
        final supabase = Supabase.instance.client;
        _session = supabase.auth.currentSession;
        _authSubscription?.cancel();
        _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
          if (mounted) {
            setState(() {
              _session = data.session;
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      debugPrint("Auth init error: $e");
      _initError = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    SupabaseManager().removeListener(_onServerChanged);
    _authSubscription?.cancel();
    super.dispose();
  }

  void _onServerChanged() {
    if (mounted) {
      _initAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
        ),
      );
    }

    if (!SupabaseManager().initialized || _initError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.deepPurpleAccent),
                const SizedBox(height: 16),
                const Text(
                  "Erreur de connexion au serveur",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _initError ?? "Impossible de se connecter au service Supabase.",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _initAuth,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réessayer"),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ServerPickerPage()),
                    );
                    _initAuth();
                  },
                  icon: const Icon(Icons.dns),
                  label: const Text("Changer de serveur"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_session != null) {
      return const MainPage();
    } else {
      return const LoginPage();
    }
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    PeoplePage(),
    LikePage(),
    ChatPage(),
    ProfileScreen(),
    HealthPage(),
  ];

  @override
  void initState() {
    super.initState();
    updateUserLocation();
    updateUserActivity();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
