import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final darkTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.deepPurple,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark background color
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bienvenue 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour continuer',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                Theme(
                  data: darkTheme,
                  child: SupaEmailAuth(
                    redirectTo: kIsWeb ? null : 'io.supabase.flutter://callback',
                    onSignInComplete: (response) {
                      updateUserLocation();
                      updateUserActivity();
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    onSignUpComplete: (response) {
                      debugPrint('🆕 Compte créé : ${response.user?.email}');
                    },
                    metadataFields: const [],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1, color: Colors.white24)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OU', style: TextStyle(color: Colors.white70)),
                    ),
                    const Expanded(child: Divider(thickness: 1, color: Colors.white24)),
                  ],
                ),

                const SizedBox(height: 24),

                SupaSocialsAuth(
                  socialProviders: const [OAuthProvider.google],
                  colored: true,
                  redirectUrl: kIsWeb ? null : 'io.supabase.flutter://callback',
                  showSuccessSnackBar: false,
                  onSuccess: (session) {
                    updateUserLocation();
                    updateUserActivity();
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  onError: (error) {
                    debugPrint('❌ Erreur : $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : $error')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
