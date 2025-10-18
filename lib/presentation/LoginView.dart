import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour continuer',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // ✅ Auth form email/password (fourni par supabase_auth_ui)
                SupaEmailAuth(
                  redirectTo: kIsWeb ? null : 'io.supabase.flutter://callback',
                  onSignInComplete: (response) {
                    debugPrint('✅ Connexion réussie : ${response.user?.email}');
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  onSignUpComplete: (response) {
                    debugPrint('🆕 Compte créé : ${response.user?.email}');
                  },
                  metadataFields: const [],
                ),

                const SizedBox(height: 24),

                // ✅ Divider
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OU'),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),

                const SizedBox(height: 24),

                // ✅ Bouton de connexion Google
                SupaSocialsAuth(
                  socialProviders: const [OAuthProvider.google],
                  colored: true,
                  redirectUrl: kIsWeb ? null : 'io.supabase.flutter://callback',
                  onSuccess: (session) {
                    debugPrint('✅ Connexion Google réussie : ${session.user.email}');
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
