import 'package:ampheria/Presentation/LoginView.dart';
import 'package:ampheria/Presentation/Page/Chat/ChatPage.dart';
import 'package:ampheria/Presentation/Page/Health/HealthPage.dart';
import 'package:ampheria/Presentation/Page/Like/LikePage.dart';
import 'package:ampheria/Presentation/Page/People/PeoplePage.dart';
import 'package:ampheria/Presentation/Page/Profile/ProfileScreen.dart';
import 'package:ampheria/Presentation/Widgets/BottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://amikone.endide.com',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzY0NzE2NDAwLCJleHAiOjE5MjI0ODI4MDB9.feIlUK_yvMG3IsfIVWkdeo7f0NHHNqWOacuAhU4rBUU',
  );
  runApp(const MyApp());
}


Future<void> updateUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }

  try {
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
    print("Erreur lors de la récupération/mise à jour de la position: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amikone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          surface: Color(0xFF1E1E2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2C),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardColor: const Color(0xFF1E1E2C),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
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
  final SupabaseClient supabase = Supabase.instance.client;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = supabase.auth.currentSession;

    supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() => _session = data.session);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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