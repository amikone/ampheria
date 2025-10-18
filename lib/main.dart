import 'package:ampheria/presentation/LoginView.dart';
import 'package:ampheria/presentation/Page/Chat/ChatPage.dart';
import 'package:ampheria/presentation/Page/Health/HealthPage.dart';
import 'package:ampheria/presentation/Page/Like/LikePage.dart';
import 'package:ampheria/presentation/Page/People/PeoplePage.dart';
import 'package:ampheria/presentation/Page/Profile/ProfilePage.dart';
import 'package:ampheria/presentation/Page/Profile/ProfileScreen.dart';
import 'package:ampheria/presentation/Widgets/BottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://alqqntyixsnbbfpxkmpp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFscXFudHlpeHNuYmJmcHhrbXBwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1MTM5MTIsImV4cCI6MjA3NjA4OTkxMn0.MlXSHlYvV3rFr_dSyLQaCkTdgnaRh-BnuzPH8-3eXWs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ampheria',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const AuthStateHandler(),
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
      setState(() => _session = data.session);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session != null) {
      return const MainPage(); // 🔹 Notre page principale avec la barre de navigation
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
